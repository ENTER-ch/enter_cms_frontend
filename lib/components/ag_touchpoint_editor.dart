import 'package:enter_cms_flutter/api/content_api.dart';
import 'package:enter_cms_flutter/bloc/ag_touchpoint_config/ag_touchpoint_config_bloc.dart';
import 'package:enter_cms_flutter/components/ag_content_preview.dart';
import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:enter_cms_flutter/components/interactive_property_text_field.dart';
import 'package:enter_cms_flutter/components/property_text_field.dart';
import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

class AGTouchpointEditor extends StatefulWidget {
  const AGTouchpointEditor({
    Key? key,
    required this.touchpoint,
  }) : super(key: key);

  final MTouchpoint touchpoint;

  @override
  State<AGTouchpointEditor> createState() => _AGTouchpointEditorState();
}

class _AGTouchpointEditorState extends State<AGTouchpointEditor> {
  late AGTouchpointConfigBloc _configBloc;

  @override
  void initState() {
    super.initState();
    _initBloc();
  }

  @override
  void didUpdateWidget(covariant AGTouchpointEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.touchpoint != widget.touchpoint) {
      _initBloc();
    }
  }

  void _initBloc() {
    _configBloc = AGTouchpointConfigBloc(
      contentApi: getIt<ContentApi>(),
      touchpoint: widget.touchpoint,
    );
    _configBloc.add(const AGTouchpointConfigEventInit());
  }

  @override
  Widget build(BuildContext context) {
    return ContentNavWidget(
      title: const Text('Audioguide'),
      child: BlocBuilder<AGTouchpointConfigBloc, AGTouchpointConfigState>(
        bloc: _configBloc,
        builder: (context, state) {
          if (state is AGTouchpointConfigLoading) {
            return Column(
              children: const [
                LinearProgressIndicator(),
              ],
            );
          }

          if (state is AGTouchpointConfigLoaded) {
            return ListView.builder(
              itemCount: state.config.contents.length,
              itemBuilder: (context, index) {
                return ListTileTheme(
                  dense: true,
                  child: ExpansionTile(
                    initiallyExpanded: index == 0,
                    controlAffinity: ListTileControlAffinity.leading,
                    tilePadding: const EdgeInsets.only(left: 12.0, right: 16.0),
                    // leading: Icon(
                    //   state.config.contents[index].type.icon,
                    //   color: Theme.of(context).colorScheme.onBackground,
                    //   size: 16,
                    // ),
                    trailing: Text(
                      state.config.contents[index].language?.toUpperCase() ??
                          '?',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    title: Text((state.config.contents[index].label ?? '').replaceAll('\n', ' '), overflow: TextOverflow.fade, softWrap: false,),
                    children: [
                      AGContentEditor(
                          configBloc: _configBloc,
                          content: state.config.contents[index]),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class AGContentEditor extends StatefulWidget {
  const AGContentEditor({
    Key? key,
    required this.configBloc,
    required this.content,
  }) : super(key: key);

  final AGTouchpointConfigBloc configBloc;
  final MAGContent content;

  @override
  State<AGContentEditor> createState() => _AGContentEditorState();
}

class _AGContentEditorState extends State<AGContentEditor> {
  String _labelValue = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildForm(),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        SizedBox(
          width: 120,
          child: AGContentPreview(
            touchpointId: widget.configBloc.touchpoint.id,
            content: widget.content.copyWith(label: _labelValue),
          ),
        ),
        const SizedBox(height: 8),
        InteractivePropertyTextField(
          initialValue: widget.content.label,
          labelText: 'Label',
          onValueChanged: (value) async {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _labelValue = value;
              });
            });
          },
          onValidate: (value) async {
            if (value.isEmpty) {
              return 'Label cannot be empty';
            }
            return null;
          },
          onSave: (value) async {
            widget.configBloc.add(AGTouchpointConfigEventUpdateContent(
                content: widget.content.copyWith(label: value)));
          },
          //maxLines: 5,
        ),
      ],
    );
  }
}