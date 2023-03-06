import 'package:enter_cms_flutter/api/content_api.dart';
import 'package:enter_cms_flutter/api/media_api.dart';
import 'package:enter_cms_flutter/bloc/ag_touchpoint_config/ag_touchpoint_config_bloc.dart';
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
            return const Column(
              children: [
                LinearProgressIndicator(),
              ],
            );
          }

          if (state is AGTouchpointConfigLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: InteractivePropertyDropdownField(
                    initialValue: state.config.playbackMode,
                    labelText: 'Play Mode',
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
                      _configBloc.add(AGTouchpointConfigEventUpdateConfig(
                          config: state.config.copyWith(playbackMode: value)));
                    },
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.config.contents.length,
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
                          state.config.contents[index].language
                                  ?.toUpperCase() ??
                              '?',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        title: Text(
                          (state.config.contents[index].label ?? '')
                              .replaceAll('\n', ' '),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                        children: [
                          AGContentEditor(
                              configBloc: _configBloc,
                              content: state.config.contents[index]),
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
        InteractivePropertyDropdownField(
          initialValue: widget.content.language,
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
            widget.configBloc.add(AGTouchpointConfigEventUpdateContent(
                content: widget.content.copyWith(language: value)));
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: MediaTrackField(
            label: 'Audio',
            trackId: widget.content.mediaTrackId,
            onUpload: (track) {
              widget.configBloc.add(AGTouchpointConfigEventUpdateContent(
                  content: widget.content.copyWith(mediaTrackId: track.id)));
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
  final _mediaApi = getIt<MediaApi>();

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

    final track = await _mediaApi.getMediaTrack(trackId);

    setState(() {
      _track = track;
      _isLoading = false;
    });
  }

  void _onEdit() async {
    final result = await showDialog<MediaUploadResult>(
      context: context,
      builder: (context) => const MediaUploadDialog(),
    );

    if (result != null) {
      final track = await _mediaApi.createMediaTrack(
        MMediaTrack(
          source: result.file.id,
          type: result.file.type,
          filename: result.file.name,
          streamId: result.streamId ?? 0,
        ),
      );

      widget.onUpload?.call(track);
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
          Text(widget.label ?? 'Media', style: Theme.of(context).textTheme.titleSmall),
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
