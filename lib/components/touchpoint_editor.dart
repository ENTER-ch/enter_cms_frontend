import 'package:enter_cms_flutter/components/ag_touchpoint_editor.dart';
import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:enter_cms_flutter/components/toolbar_button.dart';
import 'package:enter_cms_flutter/models/checklist.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:enter_cms_flutter/pages/content/components/touchpoint_marker.dart';
import 'package:enter_cms_flutter/pages/content/content_state.dart';
import 'package:enter_cms_flutter/providers/model/beacon_provider.dart';
import 'package:enter_cms_flutter/providers/model/touchpoint_provider.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:enter_cms_flutter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TouchpointEditorWidget extends ConsumerWidget {
  const TouchpointEditorWidget({
    super.key,
    required this.touchpointId,
  });

  final int touchpointId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(touchpointProvider(touchpointId));

    return ContentNavWidget(
      title: const Text('Touchpoint'),
      child: Column(
        children: [
          TouchpointListTile(
            id: touchpointId,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              elevation: 0,
              clipBehavior: Clip.hardEdge,
              child: TouchpointChecklist(
                id: touchpointId,
              ),
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          const Divider(),
          if (state.hasValue)
            TouchpointBeaconsEditor(
              id: state.value!.id!,
            ),
          const Divider(),
          switch (state.valueOrNull?.type) {
            TouchpointType.audioguide => AGTouchpointEditor(
                id: state.value!.agConfig!.id!,
              ),
            _ => const SizedBox.shrink(),
          }
        ],
      ),
    );
  }
}

class TouchpointListTile extends HookConsumerWidget {
  final int id;

  const TouchpointListTile({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(touchpointProvider(id));
    final isEditing = useState(false);

    Widget buildTile() => state.when(
          data: (data) => ListTile(
            title: Text(data.title),
            leading: TouchpointMarker(
              icon: data.type.icon,
              label: data.touchpointIdString,
              foregroundColor: data.type.color.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
              backgroundColor: data.type.color,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                isEditing.value = true;
              },
            ),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) => ListTile(
            title: Text(error.toString()),
          ),
        );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: isEditing.value ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: !isEditing.value
            ? buildTile()
            : TouchpointEditTile(
                id: id,
                onSaved: () {
                  isEditing.value = false;
                },
              ),
      ),
    );
  }
}

class TouchpointChecklist extends HookConsumerWidget {
  final int id;

  const TouchpointChecklist({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(touchpointProvider(id));

    buildDraft() => ListTile(
          dense: true,
          leading: const Icon(Icons.edit_square),
          trailing: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              ref.read(touchpointProvider(id).notifier).updateTouchpoint(
                    status: TouchpointStatus.published,
                  );
            },
            child: const Text('Publish'),
          ),
          title: Text(
            'Draft',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: const Text(
            'This Touchpoint is ready to be published.',
          ),
          tileColor:
              Theme.of(context).colorScheme.inverseSurface.withOpacity(0.2),
          textColor: Theme.of(context).colorScheme.onSurface,
        );

    buildPublished() => ListTile(
          dense: true,
          leading: const Icon(Icons.check_circle),
          trailing: TextButton(
            style: TextButton.styleFrom(
              foregroundColor:
                  Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            onPressed: () {
              ref.read(touchpointProvider(id).notifier).updateTouchpoint(
                    status: TouchpointStatus.draft,
                  );
            },
            child: const Text('Unpublish'),
          ),
          title: Text(
            'Published',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: const Text(
            'This Touchpoint is published but has unreleased changes.',
          ),
          tileColor: Theme.of(context).colorScheme.secondaryContainer,
          textColor: Theme.of(context).colorScheme.onSecondaryContainer,
        );

    buildReleased() => ListTile(
          dense: true,
          leading: const Icon(Icons.check_circle),
          trailing: TextButton(
            style: TextButton.styleFrom(
              foregroundColor:
                  Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            onPressed: () {
              ref.read(touchpointProvider(id).notifier).updateTouchpoint(
                    status: TouchpointStatus.draft,
                  );
            },
            child: const Text('Unpublish'),
          ),
          title: Text(
            'Released',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: const Text(
            'This Touchpoint is available on devices.',
          ),
          tileColor: EnterThemeColors.green.withOpacity(0.5),
          textColor: Theme.of(context).colorScheme.onSecondaryContainer,
        );

    buildChecklist(checklist) => checklist.map(
          (MChecklistItem item) => ListTile(
            dense: true,
            leading: Icon(
              item.type.icon,
            ),
            title: Text(
              item.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: item.message != null ? Text(item.message!) : null,
            tileColor: item.type.color.withOpacity(0.5),
          ),
        );

    return state.maybeWhen(
      data: (touchpoint) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (touchpoint.checklist.isEmpty)
            switch (touchpoint.status) {
              TouchpointStatus.draft => buildDraft(),
              TouchpointStatus.published =>
                touchpoint.dirty == true ? buildPublished() : buildReleased(),
              _ => const SizedBox.shrink(),
            }
          else
            ...buildChecklist(touchpoint.checklist),
        ],
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class TouchpointEditTile extends HookConsumerWidget {
  final int id;
  final void Function()? onSaved;

  const TouchpointEditTile({
    super.key,
    required this.id,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final touchpoint = ref.watch(touchpointProvider(id));
    final formKey = GlobalKey<FormState>();
    final idController =
        useTextEditingController(text: touchpoint.value?.touchpointIdString);
    final internalTitleController =
        useTextEditingController(text: touchpoint.value?.title);

    return touchpoint.isLoading
        ? const CircularProgressIndicator()
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(context),
                    const SizedBox(height: 8.0),
                    _buildFormFields(idController, internalTitleController),
                    _buildErrorText(touchpoint, context),
                    const SizedBox(height: 8.0),
                    _buildButtons(ref, formKey, idController,
                        internalTitleController, context),
                  ],
                ),
              ),
            ),
          );
  }

  Padding _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Edit Touchpoint',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }

  Widget _buildFormFields(TextEditingController idController,
      TextEditingController internalTitleController) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIdField(idController),
          const SizedBox(width: 8.0),
          _buildInternalTitleField(internalTitleController),
        ],
      ),
    );
  }

  SizedBox _buildIdField(TextEditingController idController) {
    return SizedBox(
      width: 100,
      child: TextFormField(
        controller: idController,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter ID' : null,
        decoration: const InputDecoration(labelText: 'ID'),
      ),
    );
  }

  Expanded _buildInternalTitleField(
      TextEditingController internalTitleController) {
    return Expanded(
      child: TextFormField(
        controller: internalTitleController,
        validator: (value) => value == null || value.isEmpty
            ? 'Please enter Internal Title'
            : null,
        decoration: const InputDecoration(labelText: 'Internal Title'),
      ),
    );
  }

  Widget _buildErrorText(
      AsyncValue<MTouchpoint> touchpoint, BuildContext context) {
    return touchpoint.hasError
        ? Column(
            children: [
              const SizedBox(height: 8.0),
              Text(
                touchpoint.error.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
          )
        : Container();
  }

  Row _buildButtons(
      WidgetRef ref,
      GlobalKey<FormState> formKey,
      TextEditingController idController,
      TextEditingController internalTitleController,
      BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildCancelButton(ref),
        const SizedBox(width: 8.0),
        _buildSaveButton(
            ref, formKey, idController, internalTitleController, context),
      ],
    );
  }

  ElevatedButton _buildCancelButton(WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        ref.invalidate(touchpointProvider(id));
        onSaved?.call();
      },
      child: const Text('Cancel'),
    );
  }

  ElevatedButton _buildSaveButton(
      WidgetRef ref,
      GlobalKey<FormState> formKey,
      TextEditingController idController,
      TextEditingController internalTitleController,
      BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          await ref.read(touchpointProvider(id).notifier).updateTouchpoint(
                touchpointId: int.parse(idController.text),
                internalTitle: internalTitleController.text,
              );
          final state = ref.read(touchpointProvider(id));
          state.whenData((data) => onSaved?.call());
        }
      },
      child: const Text('Save'),
    );
  }
}

class TouchpointBeaconsEditor extends ConsumerWidget {
  final int id;

  const TouchpointBeaconsEditor({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final touchpoint = ref.watch(touchpointProvider(id));

    onAddBeacon() async {
      final cmsApi = ref.read(cmsApiProvider);
      await cmsApi.createBeacon(touchpointId: id);
      ref.invalidate(contentViewControllerProvider);
    }

    return ContentNavWidget(
      title: const Text('Beacons'),
      actions: [
        ToolbarButton(
          icon: Icons.add,
          onTap: onAddBeacon,
        ),
      ],
      child: touchpoint.maybeWhen(
        data: (data) => Column(
          children: [
            for (final beaconId in data.beaconIds)
              BeaconListTile(
                id: beaconId,
              ),
          ],
        ),
        loading: () => const LinearProgressIndicator(),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class BeaconListTile extends ConsumerWidget {
  const BeaconListTile({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(beaconProvider(id));

    return state.maybeWhen(
      data: (beacon) => ListTile(
        dense: true,
        title: Text(beacon.beaconId ?? 'No ID'),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
