import 'package:enter_cms_flutter/api/cms_api.dart';
import 'package:enter_cms_flutter/bloc/touchpoint_editor/touchpoint_editor_bloc.dart';
import 'package:enter_cms_flutter/components/ag_touchpoint_editor.dart';
import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:enter_cms_flutter/components/interactive_property_dropdown_field.dart';
import 'package:enter_cms_flutter/components/interactive_property_text_field.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:enter_cms_flutter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TouchpointEditorWidget extends StatefulWidget {
  const TouchpointEditorWidget({
    Key? key,
    this.touchpoint,
    this.onTouchpointLoaded,
  }) : super(key: key);

  final MTouchpoint? touchpoint;
  final void Function(MTouchpoint touchpoint)? onTouchpointLoaded;

  @override
  State<TouchpointEditorWidget> createState() => _TouchpointEditorWidgetState();
}

class _TouchpointEditorWidgetState extends State<TouchpointEditorWidget> {
  final cmsApi = getIt<CmsApi>();

  late TouchpointEditorBloc _touchpointEditorBloc;

  final _idController = TextEditingController();
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _touchpointEditorBloc = TouchpointEditorBloc(cmsApi: cmsApi);
    _initBloc(widget.touchpoint?.id);
  }

  @override
  void didUpdateWidget(covariant TouchpointEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.touchpoint?.id != widget.touchpoint?.id) {
      _initBloc(widget.touchpoint?.id);
    }
  }

  void _initBloc(int? id) {
    if (id != null) {
      _touchpointEditorBloc.add(TouchpointEditorEventLoad(touchpointId: id));
    } else {
      _touchpointEditorBloc.add(const TouchpointEditorEventReset());
    }
  }

  void _initForm(MTouchpoint touchpoint) {
    _titleController.text = touchpoint.internalTitle ?? '';
    _idController.text = touchpoint.touchpointId.toString();
  }

  void _onTouchpointEditorStateChanged(
      BuildContext context, TouchpointEditorState state) {
    if (state is TouchpointEditorLoaded) {
      widget.onTouchpointLoaded?.call(state.touchpoint);
      _initForm(state.touchpoint);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TouchpointEditorBloc, TouchpointEditorState>(
      bloc: _touchpointEditorBloc,
      listener: _onTouchpointEditorStateChanged,
      builder: (context, state) {
        if (state is TouchpointEditorLoading) {
          return const LinearProgressIndicator();
        }
        if (state is TouchpointEditorError) {
          return Text(state.message);
        }
        if (state is TouchpointEditorLoaded) {
          return ContentNavWidget(
            title: const Text('Touchpoint'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.touchpoint.status == TouchpointStatus.published &&
                    state.touchpoint.dirty == true)
                  _buildUnpublishedWarning(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildTouchpointForm(state),
                ),
                const Divider(),
                if (widget.touchpoint?.type == TouchpointType.audioguide)
                  AGTouchpointEditor(
                    key: ValueKey(widget.touchpoint?.id),
                    touchpointEditorBloc: _touchpointEditorBloc,
                  ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildTouchpointForm(TouchpointEditorLoaded state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InteractivePropertyTextField(
          labelText: 'ID',
          controller: _idController,
          loading: state.idLoading,
          error: state.idError,
          initialValue: state.touchpoint.touchpointId.toString() ?? '',
          onSave: (value) async {
            _touchpointEditorBloc.add(TouchpointEditorEventUpdateId(
              id: value,
            ));
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
          controller: _titleController,
          loading: state.titleLoading,
          error: state.titleError,
          initialValue: state.touchpoint.internalTitle ?? '',
          onSave: (value) async {
            _touchpointEditorBloc
                .add(TouchpointEditorEventUpdateTitle(title: value));
          },
        ),
        InteractivePropertyDropdownField(
          labelText: 'Status',
          loading: state.statusLoading,
          errorMessage: state.statusError,
          initialValue: state.touchpoint.status,
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
            _touchpointEditorBloc.add(TouchpointEditorEventUpdateStatus(
              status: value,
            ));
          },
        ),
      ],
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
          Expanded(child: Text('This touchpoint has unreleased changes. Create a new Release to publish them.')),
        ],
      ),
    );
  }
}
