import 'package:enter_cms_flutter/providers/model/release_provider.dart';
import 'package:enter_cms_flutter/providers/model/touchpoint_provider.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CreateReleaseDialog extends HookConsumerWidget {
  const CreateReleaseDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releasePreview = ref.watch(releasePreviewProvider);

    final releaseNotesController = useTextEditingController();

    onCreate() async {
      await ref.read(cmsApiProvider).createRelease(
            title: releaseNotesController.text,
          );
      ref.invalidate(releaseProvider(null));
      ref.invalidate(touchpointProvider);
      if (context.mounted) Navigator.of(context).pop();
    }

    return Dialog(
      elevation: 0,
      child: SizedBox(
        width: 800,
        height: 500,
        child: IntrinsicHeight(
          child: Column(
            children: [
              ListTile(
                title: Text('Create Release',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const Divider(),
              Expanded(
                child: releasePreview.maybeWhen(
                  orElse: () => const SizedBox.shrink(),
                  data: (data) {
                    return Column(
                      children: [
                        ListTile(
                            title: Text(
                                "This release will contain ${data.count} touchpoints.")),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: releaseNotesController,
                            maxLines: 10,
                            decoration: const InputDecoration(
                              hintText: 'Release notes',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: onCreate,
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
