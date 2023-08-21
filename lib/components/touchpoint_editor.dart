import 'package:enter_cms_flutter/components/ag_touchpoint_editor.dart';
import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:enter_cms_flutter/components/interactive_property_dropdown_field.dart';
import 'package:enter_cms_flutter/components/interactive_property_text_field.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:enter_cms_flutter/providers/state/touchpoint_detail.dart';
import 'package:enter_cms_flutter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TouchpointEditorWidget extends HookConsumerWidget {
  const TouchpointEditorWidget({
    Key? key,
    required this.touchpointId,
  }) : super(key: key);

  final int touchpointId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget buildTouchpointForm(MTouchpoint touchpoint) {
      final idState = ref.watch(touchpointIdFieldProvider);
      final titleState = ref.watch(touchpointInternalTitleFieldProvider);
      final statusState = ref.watch(touchpointStatusFieldProvider);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InteractivePropertyTextField(
            labelText: 'ID',
            loading: idState.isLoading,
            error: idState.error?.toString(),
            initialValue: idState.valueOrNull?.toString() ?? '',
            onSave: (value) async {
              final int? id = int.tryParse(value);
              if (id == null) return;
              ref.read(touchpointIdFieldProvider.notifier).updateValue(id);
            },
            onValidate: (value) async {
              if (value.isEmpty) {
                return 'ID is required';
              }
              if (int.tryParse(value) == null) {
                return 'ID must be a number';
              }
              return null;
            },
          ),
          InteractivePropertyTextField(
            labelText: 'Title',
            loading: titleState.isLoading,
            error: titleState.error?.toString(),
            initialValue: titleState.valueOrNull ?? '',
            onSave: (value) async {
              ref
                  .read(touchpointInternalTitleFieldProvider.notifier)
                  .updateValue(value);
            },
          ),
          InteractivePropertyDropdownField(
            labelText: 'Status',
            loading: statusState.isLoading,
            errorMessage: statusState.error?.toString(),
            initialValue: statusState.valueOrNull ?? TouchpointStatus.draft,
            items: const [
              DropdownMenuItem(
                value: TouchpointStatus.draft,
                child: Text('Draft'),
              ),
              DropdownMenuItem(
                value: TouchpointStatus.published,
                child: Text('Published'),
              ),
            ],
            onSave: (value) async {
              ref
                  .read(touchpointStatusFieldProvider.notifier)
                  .updateValue(value);
            },
          ),
        ],
      );
    }

    final touchpoint = ref.watch(touchpointDetailStateProvider);

    return ContentNavWidget(
      title: const Text('Touchpoint'),
      child: touchpoint.maybeWhen(
        data: (touchpoint) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (touchpoint.status == TouchpointStatus.published &&
                touchpoint.dirty == true)
              _buildUnpublishedWarning(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildTouchpointForm(touchpoint),
            ),
            const Divider(),
            if (touchpoint.type == TouchpointType.audioguide)
              const AGTouchpointEditor(),
            // if (widget.touchpoint?.type == TouchpointType.mediaplayer)
            //   MPTouchpointEditor(
            //     key: ValueKey(widget.touchpoint?.id),
            //     touchpointEditorBloc: _touchpointEditorBloc,
            //   ),
          ],
        ),
        loading: () => const LinearProgressIndicator(),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildUnpublishedWarning() {
    return Container(
      color: EnterThemeColors.orange,
      padding: const EdgeInsets.all(8.0),
      child: const Row(
        children: [
          Icon(Icons.warning),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
                'This touchpoint has unreleased changes. Create a new Release to publish them.'),
          ),
        ],
      ),
    );
  }

// final cmsApi = getIt<CmsApi>();
//
// late TouchpointEditorBloc _touchpointEditorBloc;
//
// final _idController = TextEditingController();
// final _titleController = TextEditingController();
//
// @override
// void initState() {
//   super.initState();
//   _touchpointEditorBloc = TouchpointEditorBloc(cmsApi: cmsApi);
//   _initBloc(widget.touchpoint?.id);
// }
//
// @override
// void didUpdateWidget(covariant TouchpointEditorWidget oldWidget) {
//   super.didUpdateWidget(oldWidget);
//
//   if (oldWidget.touchpoint?.id != widget.touchpoint?.id) {
//     _initBloc(widget.touchpoint?.id);
//   }
// }
//
// void _initBloc(int? id) {
//   if (id != null) {
//     _touchpointEditorBloc.add(TouchpointEditorEventLoad(touchpointId: id));
//   } else {
//     _touchpointEditorBloc.add(const TouchpointEditorEventReset());
//   }
// }
//
// void _initForm(MTouchpoint touchpoint) {
//   _titleController.text = touchpoint.internalTitle ?? '';
//   _idController.text = touchpoint.touchpointId.toString();
// }
//
// void _onTouchpointEditorStateChanged(
//     BuildContext context, TouchpointEditorState state) {
//   if (state is TouchpointEditorLoaded) {
//     widget.onTouchpointLoaded?.call(state.touchpoint);
//     _initForm(state.touchpoint);
//   }
// }
//
// @override
// Widget build(BuildContext context) {
//   return BlocConsumer<TouchpointEditorBloc, TouchpointEditorState>(
//     bloc: _touchpointEditorBloc,
//     listener: _onTouchpointEditorStateChanged,
//     builder: (context, state) {
//       if (state is TouchpointEditorLoading) {
//         return const LinearProgressIndicator();
//       }
//       if (state is TouchpointEditorError) {
//         return Text(state.message);
//       }
//       if (state is TouchpointEditorLoaded) {
//         return ContentNavWidget(
//           title: const Text('Touchpoint'),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (state.touchpoint.status == TouchpointStatus.published &&
//                   state.touchpoint.dirty == true)
//                 _buildUnpublishedWarning(),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: _buildTouchpointForm(state),
//               ),
//               const Divider(),
//               if (widget.touchpoint?.type == TouchpointType.audioguide)
//                 AGTouchpointEditor(
//                   key: ValueKey(widget.touchpoint?.id),
//                   touchpointEditorBloc: _touchpointEditorBloc,
//                 ),
//               if (widget.touchpoint?.type == TouchpointType.mediaplayer)
//                 MPTouchpointEditor(
//                   key: ValueKey(widget.touchpoint?.id),
//                   touchpointEditorBloc: _touchpointEditorBloc,
//                 ),
//             ],
//           ),
//         );
//       }
//       return const SizedBox();
//     },
//   );
// }
//

//
// Widget _buildUnpublishedWarning() {
//   return Container(
//     color: EnterThemeColors.orange,
//     padding: const EdgeInsets.all(8.0),
//     child: const Row(
//       children: [
//         Icon(Icons.warning),
//         SizedBox(width: 8.0),
//         Expanded(child: Text('This touchpoint has unreleased changes. Create a new Release to publish them.')),
//       ],
//     ),
//   );
// }
}
