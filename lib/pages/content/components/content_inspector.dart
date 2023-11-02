import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:enter_cms_flutter/components/touchpoint_editor.dart';
import 'package:enter_cms_flutter/pages/content/content_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InspectorPane extends ConsumerWidget {
  const InspectorPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTouchpointId = ref.watch(selectedTouchpointIdProvider);
    return ContentNavWidget(
      title: const Text('Editor'),
      child: Expanded(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedTouchpointId != null)
                TouchpointEditorWidget(
                  key: ValueKey(selectedTouchpointId),
                  touchpointId: selectedTouchpointId,
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select a touchpoint to start editing.',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
