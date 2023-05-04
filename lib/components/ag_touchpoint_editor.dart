import 'package:enter_cms_flutter/api/cms_api.dart';
import 'package:enter_cms_flutter/api/content_api.dart';
import 'package:enter_cms_flutter/api/media_api.dart';
import 'package:enter_cms_flutter/bloc/ag_touchpoint_config/ag_touchpoint_config_bloc.dart';
import 'package:enter_cms_flutter/bloc/touchpoint_editor/touchpoint_editor_bloc.dart';
import 'package:enter_cms_flutter/components/ag_content_preview.dart';
import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:enter_cms_flutter/components/inline_audio_player.dart';
import 'package:enter_cms_flutter/components/interactive_property_dropdown_field.dart';
import 'package:enter_cms_flutter/components/interactive_property_text_field.dart';
import 'package:enter_cms_flutter/components/media_upload_dialog.dart';
import 'package:enter_cms_flutter/components/property_dropdown_field.dart';
import 'package:enter_cms_flutter/components/property_text_field.dart';
import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/media_track.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

class AGTouchpointEditor extends StatelessWidget {
  const AGTouchpointEditor({
    Key? key,
    required this.touchpointEditorBloc,
  }) : super(key: key);

  final TouchpointEditorBloc touchpointEditorBloc;

  @override
  Widget build(BuildContext context) {
    return ContentNavWidget(
      title: const Text('Audioguide'),
      child: BlocBuilder<TouchpointEditorBloc, TouchpointEditorState>(
        bloc: touchpointEditorBloc,
        builder: (context, state) {
          if (state is TouchpointEditorLoaded) {
            final config = state.touchpoint.agConfig!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: InteractivePropertyDropdownField(
                    initialValue: config.playbackMode,
                    labelText: 'Play Mode',
                    loading: state.configLoading,
                    errorMessage: state.configError,
                    items: [
                      DropdownMenuItem(
                          value: AGPlaybackMode.autoLoop,
                          child: Text(AGPlaybackMode.autoLoop.label)),
                      DropdownMenuItem(
                          value: AGPlaybackMode.autoSingle,
                          child: Text(AGPlaybackMode.autoSingle.label)),
                      DropdownMenuItem(
                          value: AGPlaybackMode.prompt,
                          child: Text(AGPlaybackMode.prompt.label)),
                    ],
                    onValidate: (value) async {
                      if (value == null) {
                        return 'Mode cannot be empty';
                      }
                      return null;
                    },
                    onSave: (value) async {
                      touchpointEditorBloc.add(
                        TouchpointEditorEventUpdateAGTouchpointConfig(
                          playbackMode: value!,
                        ),
                      );
                    },
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: config.contents.length,
                  itemBuilder: (context, index) {
                    return ListTileTheme(
                      dense: true,
                      child: ExpansionTile(
                        initiallyExpanded: index == 0,
                        controlAffinity: ListTileControlAffinity.leading,
                        tilePadding:
                            const EdgeInsets.only(left: 12.0, right: 16.0),
                        // leading: Icon(
                        //   state.config.contents[index].type.icon,
                        //   color: Theme.of(context).colorScheme.onBackground,
                        //   size: 16,
                        // ),
                        trailing: Text(
                          config.contents[index].language?.toUpperCase() ?? '?',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        title: Text(
                          (config.contents[index].label ?? '')
                              .replaceAll('\n', ' '),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                        children: [
                          AGContentEditor(
                            key: ValueKey(config.contents[index].id),
                            touchpointEditorBloc: touchpointEditorBloc,
                            index: index,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
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
    required this.touchpointEditorBloc,
    required this.index,
  }) : super(key: key);

  final TouchpointEditorBloc touchpointEditorBloc;
  final int index;

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
    return BlocBuilder<TouchpointEditorBloc, TouchpointEditorState>(
      bloc: widget.touchpointEditorBloc,
      builder: (context, state) {
        if (state is TouchpointEditorLoaded) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildForm(state),
          );
        }
        return const SizedBox();
      }
    );
  }

  Widget _buildForm(TouchpointEditorLoaded state) {
    final touchpoint = state.touchpoint;
    final content = touchpoint.agConfig!.contents[widget.index];

    return Column(
      key: ValueKey(content.id),
      children: [
        SizedBox(
          width: 120,
          child: AGContentPreview(
            touchpointId: touchpoint.touchpointId,
            content: content.copyWith(label: _labelValue),
          ),
        ),
        const SizedBox(height: 8),
        InteractivePropertyTextField(
          initialValue: content.label,
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
            widget.touchpointEditorBloc.add(TouchpointEditorEventUpdateAGContent(
              content.id!,
              label: value,
            ));
          },
        ),
        InteractivePropertyDropdownField(
          initialValue: content.language,
          labelText: 'Language',
          items: const [
            DropdownMenuItem(value: 'de', child: Text('Deutsch')),
            DropdownMenuItem(value: 'en', child: Text('Englisch')),
            DropdownMenuItem(value: 'fr', child: Text('Francais')),
          ],
          onValidate: (value) async {
            if (value == null) {
              return 'Language cannot be empty';
            }
            return null;
          },
          onSave: (value) async {
            widget.touchpointEditorBloc.add(TouchpointEditorEventUpdateAGContent(
              content.id!,
              language: value,
            ));
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: MediaTrackField(
            label: 'Audio',
            trackId: content.mediaTrackId,
            onUpload: (track) {
              widget.touchpointEditorBloc.add(
                TouchpointEditorEventUpdateAGContent(
                  content.id!,
                  mediaTrackId: track.id,
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

class MediaTrackField extends StatefulWidget {
  const MediaTrackField({
    super.key,
    this.label,
    this.trackId,
    this.onUpload,
  });

  final String? label;

  final int? trackId;

  final void Function(MMediaTrack track)? onUpload;

  @override
  State<MediaTrackField> createState() => _MediaTrackFieldState();
}

class _MediaTrackFieldState extends State<MediaTrackField> {
  final _cmsApi = getIt<CmsApi>();

  MMediaTrack? _track;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.trackId != null) {
      _loadMediaTrack(widget.trackId!);
    }
  }

  @override
  void didUpdateWidget(covariant MediaTrackField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackId != widget.trackId) {
      if (widget.trackId != null) {
        _loadMediaTrack(widget.trackId!);
      } else {
        setState(() {
          _track = null;
        });
      }
    }
  }

  void _loadMediaTrack(int trackId) async {
    // Load Track
    setState(() {
      _isLoading = true;
    });

    final track = await _cmsApi.getMediaTrack(trackId);

    setState(() {
      _track = track;
      _isLoading = false;
    });
  }

  void _onEdit() async {
    final result = await showDialog<MMediaTrack>(
      context: context,
      builder: (context) => const MediaUploadDialog(),
    );

    if (result != null) {
      widget.onUpload?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LinearProgressIndicator();
    }

    if (_track == null) {
      // Create
      return TextButton(
        onPressed: _onEdit,
        child: const Center(child: Text('Add Media')),
      );
    }

    // Preview / Edit
    if (_track != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label ?? 'Media',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (_track!.type == MediaType.audio && _track!.previewUrl != null)
            InlineAudioPlayer(
              url: _track!.previewUrl!,
            ),
          const SizedBox(height: 8),
          Text(
            _track!.filename ?? '',
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _onEdit,
            child: const Center(child: Text('Change Media')),
          ),
        ],
      );
    }
    return const SizedBox();
  }
}
