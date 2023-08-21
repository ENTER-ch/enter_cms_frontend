import 'package:enter_cms_flutter/components/toolbar_button.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:enter_cms_flutter/pages/content/content_state.dart';
import 'package:enter_cms_flutter/pages/content/content_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentToolbar extends ConsumerWidget {
  const ContentToolbar({Key? key}) : super(key: key);

  void _onCreateTouchpoint(WidgetRef ref, TouchpointType type) {
    ref
        .read(contentMapToolControllerProvider.notifier)
        .selectTool(CreateTouchpointTool(ref, type: type));
  }

  Widget _buildCancelIntentButton(BuildContext context, WidgetRef ref) {
    return ToolbarButton(
      icon: Icons.close,
      label: 'Cancel',
      tooltipText: 'Cancel',
      onTap: () {
        ref.read(contentMapToolControllerProvider.notifier).cancelTool();
      },
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Row(children: [
      ToolbarButton(
        icon: Icons.headphones,
        label: 'Create Audioguide',
        tooltipText: 'Create Audioguide Touchpoint',
        onTap: () => _onCreateTouchpoint(ref, TouchpointType.audioguide),
      ),
      ToolbarButton(
        icon: Icons.tv,
        label: 'Create Mediaplayer',
        tooltipText: 'Create Mediaplayer Touchpoint',
        onTap: () => _onCreateTouchpoint(ref, TouchpointType.mediaplayer),
      ),
      const Spacer(),
      ToolbarButton(
        icon: Icons.refresh,
        tooltipText: 'Refresh',
        onTap: () {
          ref.read(contentViewControllerProvider.notifier).refreshView();
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tool = ref.watch(contentMapToolControllerProvider);
    final state = ref.watch(contentViewControllerProvider);
    return Stack(
      children: [
        if (state.isLoading) const LinearProgressIndicator(),
        tool != null
            ? _buildCancelIntentButton(context, ref)
            : _buildActions(context, ref),
      ],
    );
  }
}
