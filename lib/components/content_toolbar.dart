import 'package:enter_cms_flutter/components/toolbar_button.dart';
import 'package:enter_cms_flutter/models/floorplan.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:enter_cms_flutter/pages/content/content_state.dart';
import 'package:enter_cms_flutter/pages/content/content_tool.dart';
import 'package:enter_cms_flutter/providers/model/floorplan_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ContentToolbar extends ConsumerWidget {
  const ContentToolbar({super.key});

  Widget _buildCancelIntentButton(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ToolbarButton(
        icon: Icons.close,
        label: 'Cancel',
        tooltipText: 'Cancel',
        onTap: () {
          ref.read(contentMapToolControllerProvider.notifier).cancelTool();
        },
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return IntrinsicHeight(
      child: Row(children: [
        const ContentViewToggleButtons(),
        const VerticalDivider(),
        const FloorplanSelector(),
        const VerticalDivider(),
        const CreateTouchpointButton(
          icon: Icons.headphones,
          label: 'Create Audioguide',
          tooltipText: 'Create Audioguide Touchpoint',
          type: TouchpointType.audioguide,
        ),
        if (kDebugMode)
          const CreateTouchpointButton(
            icon: Icons.tv,
            label: 'Create Mediaplayer',
            tooltipText: 'Create Mediaplayer Touchpoint',
            type: TouchpointType.mediaplayer,
          ),
        const Spacer(),
        const VerticalDivider(),
        ToolbarButton(
          icon: Icons.refresh,
          tooltipText: 'Refresh',
          onTap: () {
            ref.read(contentViewControllerProvider.notifier).refreshView();
          },
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tool = ref.watch(contentMapToolControllerProvider);
    final state = ref.watch(contentViewControllerProvider);
    return Stack(
      children: [
        if (state.isLoading) const LinearProgressIndicator(),
        _buildActions(context, ref),
        if (tool != null) _buildCancelIntentButton(context, ref)
      ],
    );
  }
}

class FloorplanSelector extends ConsumerWidget {
  const FloorplanSelector({super.key});

  void _onChanged(BuildContext context, WidgetRef ref, int floorplanId) {
    final selectedFloorplanId = ref.read(selectedFloorplanIdProvider);
    if (selectedFloorplanId != floorplanId) {
      context.goNamed(
        'content-floorplan',
        pathParameters: {
          'floorplanId': floorplanId.toString(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final floorplans = ref.watch(floorplanManagerProvider);
    final selectedFloorplan = ref.watch(selectedFloorplanProvider);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100),
      child: Tooltip(
        message: 'Select Floorplan',
        child: DropdownButton<MFloorplan>(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          underline: const SizedBox(),
          isDense: true,
          value: selectedFloorplan,
          style: Theme.of(context).textTheme.titleSmall,
          onChanged: (MFloorplan? newValue) =>
              _onChanged(context, ref, newValue!.id),
          items: floorplans.maybeWhen(
            data: (data) => data
                .map(
                  (MFloorplan el) => DropdownMenuItem<MFloorplan>(
                    value: el,
                    child: Text(
                      el.title ?? 'Untitled',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            orElse: () => const [],
          ),
        ),
      ),
    );
  }
}

class ContentViewToggleButtons extends ConsumerWidget {
  const ContentViewToggleButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContentView = ref.watch(selectedContentViewProvider);

    return ToggleButtons(
      renderBorder: false,
      constraints: const BoxConstraints.tightFor(
        width: 36,
        height: 36,
      ),
      onPressed: (int index) {
        ref.read(selectedContentViewProvider.notifier).set(switch (index) {
              0 => ContentView.list,
              int() => ContentView.map,
            });
      },
      isSelected: [
        selectedContentView == ContentView.list,
        selectedContentView == ContentView.map,
      ],
      children: const <Widget>[
        Icon(Icons.list),
        Icon(Icons.map),
      ],
    );
  }
}

class CreateTouchpointButton extends ConsumerWidget {
  final IconData icon;
  final String label;
  final String tooltipText;
  final TouchpointType type;

  const CreateTouchpointButton({
    super.key,
    required this.icon,
    required this.label,
    required this.tooltipText,
    required this.type,
  });

  void _onCreateTouchpoint(WidgetRef ref) {
    ref.read(selectedContentViewProvider.notifier).set(ContentView.map);
    ref
        .read(contentMapToolControllerProvider.notifier)
        .selectTool(CreateTouchpointTool(ref, type: type));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ToolbarButton(
      icon: icon,
      label: label,
      tooltipText: tooltipText,
      onTap: () => _onCreateTouchpoint(ref),
    );
  }
}
