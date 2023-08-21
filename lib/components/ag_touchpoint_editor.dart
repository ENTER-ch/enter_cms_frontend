import 'package:enter_cms_flutter/components/ag_content_preview.dart';
import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:enter_cms_flutter/components/inline_audio_player.dart';
import 'package:enter_cms_flutter/components/interactive_property_dropdown_field.dart';
import 'package:enter_cms_flutter/components/interactive_property_text_field.dart';
import 'package:enter_cms_flutter/components/media_upload_dialog.dart';
import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/media_track.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:enter_cms_flutter/providers/state/ag_content_editor.dart';
import 'package:enter_cms_flutter/providers/state/ag_touchpoint_editor.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

GetIt getIt = GetIt.instance;

class AGTouchpointEditor extends HookConsumerWidget {
  const AGTouchpointEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackModeField = ref.watch(aGTouchpointPlaybackModeFieldProvider);

    return ContentNavWidget(
      title: const Text('Audioguide'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: InteractivePropertyDropdownField(
              initialValue:
                  playbackModeField.valueOrNull ?? AGPlaybackMode.autoSingle,
              labelText: 'Play Mode',
              loading: playbackModeField.isLoading,
              errorMessage: playbackModeField.error?.toString(),
              items: [
                DropdownMenuItem(
                  value: AGPlaybackMode.autoLoop,
                  child: Text(AGPlaybackMode.autoLoop.label),
                ),
                DropdownMenuItem(
                  value: AGPlaybackMode.autoSingle,
                  child: Text(AGPlaybackMode.autoSingle.label),
                ),
                DropdownMenuItem(
                  value: AGPlaybackMode.prompt,
                  child: Text(AGPlaybackMode.prompt.label),
                ),
              ],
              onValidate: (value) async {
                if (value == null) {
                  return 'Mode cannot be empty';
                }
                return null;
              },
              onSave: (value) async {
                ref
                    .read(aGTouchpointPlaybackModeFieldProvider.notifier)
                    .updateValue(value);
              },
            ),
          ),
          const Divider(),
          const AGContentEditor(),
          // if (config != null)
          //   ListView.builder(
          //     shrinkWrap: true,
          //     itemCount: config.contents.length,
          //     itemBuilder: (context, index) {
          //       return ListTileTheme(
          //         dense: true,
          //         child: ExpansionTile(
          //           initiallyExpanded: index == 0,
          //           controlAffinity: ListTileControlAffinity.leading,
          //           tilePadding: const EdgeInsets.only(left: 12.0, right: 16.0),
          //           // leading: Icon(
          //           //   state.config.contents[index].type.icon,
          //           //   color: Theme.of(context).colorScheme.onBackground,
          //           //   size: 16,
          //           // ),
          //           trailing: Text(
          //             config.contents[index].language?.toUpperCase() ?? '?',
          //             style: Theme.of(context).textTheme.titleSmall,
          //           ),
          //           title: Text(
          //             (config.contents[index].label ?? '')
          //                 .replaceAll('\n', ' '),
          //             overflow: TextOverflow.fade,
          //             softWrap: false,
          //           ),
          //           children: [
          //             AGContentEditor(
          //               key: ValueKey(config.contents[index].id),
          //               id: config.contents[index].id!,
          //             ),
          //           ],
          //         ),
          //       );
          //     },
          //   ),
        ],
      ),
    );
  }
}

class AGContentEditor extends HookConsumerWidget {
  const AGContentEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(agTouchpointConfigProvider);
    if (config == null) return const SizedBox();

    buildContentList() {
      final selectedId = ref.watch(selectedAGContentIdProvider);
      return SizedBox(
        height: 200,
        child: ListView.builder(
          itemCount: config.contents.length,
          itemBuilder: (context, index) {
            final content = config.contents[index];
            final isSelected = content.id == selectedId;
            return ListTile(
              dense: true,
              selectedTileColor:
                  Theme.of(context).colorScheme.secondaryContainer,
              selectedColor: Theme.of(context).colorScheme.onSecondaryContainer,
              title: Text(
                content.label ?? 'Untitled',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
              trailing: Text(
                content.language?.toUpperCase() ?? '?',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              selected: isSelected,
              onTap: () {},
            );
          },
        ),
      );
    }

    final selectedContent = ref.watch(aGContentEditorProvider);
    final labelField = ref.watch(aGContentLabelFieldProvider);
    final languageField = ref.watch(aGContentLanguageFieldProvider);

    return selectedContent.maybeWhen(
      data: (content) => Container(
        height: 800,
        child: ContentNavWidget(
          title: const Text('Content'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AGContentPreview(
                    content: content,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InteractivePropertyTextField(
                  labelText: 'Label',
                  initialValue: labelField.valueOrNull,
                  loading: labelField.isLoading,
                  error: labelField.error?.toString(),
                  onSave: (value) async {
                    ref
                        .read(aGContentLabelFieldProvider.notifier)
                        .updateValue(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InteractivePropertyDropdownField(
                  labelText: 'Label',
                  initialValue: languageField.valueOrNull ?? 'de',
                  loading: languageField.isLoading,
                  items: const [
                    DropdownMenuItem(
                      value: 'de',
                      child: Text('German'),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: 'fr',
                      child: Text('French'),
                    ),
                  ],
                  onSave: (value) async {
                    ref
                        .read(aGContentLanguageFieldProvider.notifier)
                        .updateValue(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: MediaTrackField(
                  label: 'Audio',
                  trackId: content.mediaTrackId,
                  onUpload: (track) async {
                    ref
                        .read(aGContentEditorProvider.notifier)
                        .updateContent(mediaTrackId: track.id);
                  },
                ),
              ),
              buildContentList(),
            ],
          ),
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class MediaTrackField extends ConsumerStatefulWidget {
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
  ConsumerState<MediaTrackField> createState() => _MediaTrackFieldState();
}

class _MediaTrackFieldState extends ConsumerState<MediaTrackField> {
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

    final cmsApi = ref.read(cmsApiProvider);
    final track = await cmsApi.getMediaTrack(trackId);

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
              url: "/${_track!.previewUrl!}",
            ),
          const SizedBox(height: 8),
          // Text(
          //   _track!.filename ?? '',
          //   overflow: TextOverflow.ellipsis,
          // ),
          // const SizedBox(height: 8),
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
