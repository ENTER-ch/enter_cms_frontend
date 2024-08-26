import 'package:enter_cms_flutter/providers/model/beacon_provider.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BeaconEditDialog extends HookConsumerWidget {
  final int beaconId;

  const BeaconEditDialog({
    super.key,
    required this.beaconId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initializedForm = useState(false);
    final idController = useTextEditingController();
    final idText = useState<String>('');
    final errorText = useState<String?>(null);

    idController.addListener(() {
      idText.value = idController.text;
    });

    if (initializedForm.value == false) {
      final beaconState = ref.watch(beaconProvider(beaconId));
      beaconState.whenData((content) {
        idController.text = content.beaconId?.toString() ?? '';
        initializedForm.value = true;
      });
    }

    onSave() async {
      final cmsApi = ref.read(cmsApiProvider);

      try {
        await cmsApi.updateBeacon(
          beaconId,
          beaconId: idText.value,
        );
      } catch (e) {
        errorText.value = e.toString();
        return;
      }

      ref.invalidate(beaconProvider(beaconId));

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    buildIdTile() => ListTile(
          title: TextField(
            autofocus: true,
            controller: idController,
            decoration: InputDecoration(
              labelText: 'Beacon ID',
              errorText: errorText.value,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLines: 1,
          ),
        );

    buildActions() => Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: onSave,
                child: const Text('Save'),
              )
            ],
          ),
        );

    return Dialog(
      elevation: 0,
      child: SizedBox(
        width: 400,
        height: 200,
        child: IntrinsicHeight(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Edit Beacon',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(),
              Expanded(
                child: Column(
                  children: [
                    buildIdTile(),
                  ],
                ),
              ),
              const Divider(),
              buildActions(),
            ],
          ),
        ),
      ),
    );
  }
}
