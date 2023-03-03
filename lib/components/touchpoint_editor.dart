import 'package:enter_cms_flutter/api/content_api.dart';
import 'package:enter_cms_flutter/bloc/content/content_bloc.dart';
import 'package:enter_cms_flutter/components/ag_touchpoint_editor.dart';
import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:enter_cms_flutter/components/interactive_property_text_field.dart';
import 'package:enter_cms_flutter/components/property_text_field.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:flutter/material.dart';

class TouchpointEditorWidget extends StatefulWidget {
  const TouchpointEditorWidget({
    Key? key,
    required this.contentBloc,
    this.touchpoint,
  }) : super(key: key);

  final ContentBloc contentBloc;
  final MTouchpoint? touchpoint;

  @override
  State<TouchpointEditorWidget> createState() => _TouchpointEditorWidgetState();
}

class _TouchpointEditorWidgetState extends State<TouchpointEditorWidget> {
  final contentApi = getIt<ContentApi>();
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  @override
  void didUpdateWidget(covariant TouchpointEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.touchpoint != widget.touchpoint) {
      _initForm();
    }
  }

  void _initForm() {
    if (widget.touchpoint != null) {
      _titleController.text = widget.touchpoint!.internalTitle ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ContentNavWidget(
          title: const Text('Touchpoint'),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InteractivePropertyTextField(
                  labelText: 'ID',
                  initialValue: widget.touchpoint?.touchpointId.toString() ?? '',
                  onSave: (value) async {
                    final result = await contentApi.updateTouchpoint(
                      widget.touchpoint!.copyWith(touchpointId: int.parse(value)),
                    );
                    widget.contentBloc.add(ContentEventUpdateTouchpoint(touchpoint: result));
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
                  initialValue: widget.touchpoint?.internalTitle ?? '',
                  onSave: (value) async {
                    final result = await contentApi.updateTouchpoint(
                      widget.touchpoint!.copyWith(internalTitle: value),
                    );
                    widget.contentBloc.add(ContentEventUpdateTouchpoint(touchpoint: result));
                  },
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        if (widget.touchpoint?.type == TouchpointType.audioguide)
          AGTouchpointEditor(
            touchpoint: widget.touchpoint!,
          ),
      ],
    );
  }
}