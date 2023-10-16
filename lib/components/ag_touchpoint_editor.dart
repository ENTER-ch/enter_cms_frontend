import 'package:cross_file/cross_file.dart';
import 'package:enter_cms_flutter/components/ag_content_preview.dart';
import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:enter_cms_flutter/components/inline_audio_player.dart';
import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/media_track.dart';
import 'package:enter_cms_flutter/pages/content/content_state.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:enter_cms_flutter/providers/state/touchpoint_detail.dart';
import 'package:enter_cms_flutter/theme/theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

GetIt getIt = GetIt.instance;

class AGTouchpointEditor extends HookConsumerWidget {
  final int id;

  const AGTouchpointEditor({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aGTouchpointConfigProvider(id));

    return state.maybeWhen(
      data: (config) => ContentNavWidget(
        title: const Text('Audioguide Settings'),
        child: Column(
          children: [
            AGPlaybackModeTile(id: id),
            const Divider(),
            ContentNavWidget(
              title: const Text("Content"),
              child: Column(
                children: [
                  ...config.contents
                      .map(
                        (e) => AGContentListTile(id: e.id!),
                      )
                      .toList(),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.add),
                    title: const Text('Add Content'),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (context) => AGContentEditDialog.create(
                          agTouchpointId: id,
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class AGPlaybackModeTile extends ConsumerWidget {
  const AGPlaybackModeTile({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aGTouchpointConfigProvider(id));

    return state.maybeWhen(
      data: (config) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Row(
            children: [
              const Expanded(
                child: ListTile(
                  dense: true,
                  title: Text('Playback Mode'),
                ),
              ),
              ToggleButtons(
                renderBorder: false,
                isSelected: [
                  config.playbackMode == AGPlaybackMode.autoSingle,
                  config.playbackMode == AGPlaybackMode.autoLoop,
                  config.playbackMode == AGPlaybackMode.prompt,
                ],
                onPressed: (int index) {
                  ref
                      .read(aGTouchpointConfigProvider(id).notifier)
                      .updateConfig(
                        playbackMode: AGPlaybackMode.values[index],
                      );
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AGPlaybackMode.autoSingle.label),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AGPlaybackMode.autoLoop.label),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AGPlaybackMode.prompt.label),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class AGContentListTile extends HookConsumerWidget {
  final int id;

  const AGContentListTile({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aGContentProvider(id));

    return state.maybeWhen(
      data: (content) {
        final mediaTrackState = content.mediaTrackId != null
            ? ref.watch(mediaTrackProvider(content.mediaTrackId!))
            : const AsyncValue.data(null);

        return ListTile(
          dense: true,
          title: Text(content.shortLabel),
          subtitle: mediaTrackState.valueOrNull?.previewUrl != null
              ? InlineAudioPlayer(url: mediaTrackState.value!.previewUrl!)
              : const Text('No Media'),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AGContentEditDialog.edit(
                  agContentId: id,
                ),
              );
            },
          ),
          leading: CircleAvatar(
            child: Text(
              (content.language ?? 'Unknown').toUpperCase(),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class AGContentEditDialog extends HookConsumerWidget {
  final int? agTouchpointId;
  final int? agContentId;
  final bool edit;

  static const List<Map<String, String>> _languages = [
    {
      'code': 'de',
      'label': 'German',
    },
    {
      'code': 'en',
      'label': 'English',
    },
    {
      'code': 'fr',
      'label': 'French',
    },
    {
      'code': 'it',
      'label': 'Italian',
    }
  ];

  const AGContentEditDialog({
    super.key,
    this.agTouchpointId,
    this.agContentId,
    this.edit = false,
  });

  const AGContentEditDialog.create({
    super.key,
    required this.agTouchpointId,
  })  : edit = false,
        agContentId = null;

  const AGContentEditDialog.edit({
    super.key,
    required this.agContentId,
  })  : edit = true,
        agTouchpointId = null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initializedForm = useState(false);
    final selectedLanguage = useState(_languages.first);
    final labelController = useTextEditingController();
    final labelText = useState<String>('');

    final mediaTrackId = useState<int?>(null);

    labelController.addListener(() {
      labelText.value = labelController.text;
    });

    if (edit && initializedForm.value == false) {
      final contentState = ref.watch(aGContentProvider(agContentId!));
      contentState.whenData((content) {
        labelController.text = content.label ?? '';
        labelText.value = content.label ?? '';
        selectedLanguage.value = _languages.firstWhere(
          (lang) => lang['code'] == content.language,
        );
        mediaTrackId.value = content.mediaTrackId;
        initializedForm.value = true;
      });
    }

    onSave() async {
      final cmsApi = ref.read(cmsApiProvider);

      if (edit) {
        await cmsApi.updateAGContent(
          agContentId!,
          label: labelText.value,
          language: selectedLanguage.value['code'],
          mediaTrackId: mediaTrackId.value,
          clearMediaTrackId: mediaTrackId.value == null,
        );

        ref.invalidate(aGContentProvider(agContentId!));
      } else {
        await cmsApi.createAGContent(
          agTouchpointId!,
          label: labelText.value,
          language: selectedLanguage.value['code'],
          mediaTrackId: mediaTrackId.value,
        );

        ref.invalidate(aGTouchpointConfigProvider(agTouchpointId!));
      }

      // TODO This could be made more specific
      ref.invalidate(touchpointProvider);

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    onDelete() async {
      final cmsApi = ref.read(cmsApiProvider);
      final confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content:
                const Text('Are you sure you want to delete this content?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
      if (confirmDelete) {
        await cmsApi.deleteAGContent(agContentId!);
        ref.invalidate(aGContentProvider(agContentId!));
        if (context.mounted) Navigator.of(context).pop();
      }
    }

    buildLanguageTile() => Row(
          children: [
            const Expanded(
              child: ListTile(
                dense: true,
                title: Text('Language'),
              ),
            ),
            ToggleButtons(
              onPressed: (int index) {
                selectedLanguage.value = _languages[index];
              },
              renderBorder: false,
              isSelected: _languages
                  .map((lang) => lang['code'] == selectedLanguage.value['code'])
                  .toList(),
              children: _languages
                  .map(
                    (lang) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(lang['label']!),
                    ),
                  )
                  .toList(),
            ),
          ],
        );

    buildLabelTile() => ListTile(
          title: TextField(
            controller: labelController,
            decoration: const InputDecoration(
              labelText: 'Label',
            ),
            maxLines: 4,
          ),
        );

    buildPreview() => Column(
          children: [
            ContentNavWidget(
              title: const Text('Preview'),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                ),
                child: SizedBox(
                  height: 200,
                  child: AGContentPreview(
                      content: MAGContent(
                    label: labelText.value,
                  )),
                ),
              ),
            ),
          ],
        );

    buildMediaTile() {
      if (mediaTrackId.value == null) {
        return Column(
          children: [
            const ListTile(
              dense: true,
              title: Text('Media'),
            ),
            MediaUploadListTile(
              onUpload: (track) {
                mediaTrackId.value = track.id;
              },
            ),
          ],
        );
      } else {
        final mediaTrackState =
            ref.watch(mediaTrackProvider(mediaTrackId.value!));

        return Column(
          children: [
            const ListTile(
              dense: true,
              title: Text('Media'),
            ),
            mediaTrackState.maybeWhen(
              data: (track) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: InlineAudioPlayer(url: track.previewUrl!),
              ),
              loading: () => const LinearProgressIndicator(),
              orElse: () => const SizedBox.shrink(),
            ),
            ListTile(
              dense: true,
              title: const Text('Delete Media'),
              leading: const Icon(Icons.delete),
              onTap: () {
                mediaTrackId.value = null;
              },
            ),
          ],
        );
      }
    }

    buildActions() => Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (edit)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: onDelete,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ElevatedButton(
                onPressed: onSave,
                child: const Text('Save'),
              )
            ],
          ),
        );

    return Dialog(
      elevation: 0,
      child: SizedBox(
        width: 800,
        height: 500,
        child: IntrinsicHeight(
          child: Column(
            children: [
              ListTile(
                title: Text(edit ? 'Edit Content' : 'Create Content',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const Divider(),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          buildLanguageTile(),
                          const Divider(),
                          buildLabelTile(),
                          const Divider(),
                          buildMediaTile(),
                        ],
                      ),
                    ),
                    const VerticalDivider(),
                    buildPreview(),
                  ],
                ),
              ),
              const Divider(),
              buildActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class MediaUploadListTile extends HookConsumerWidget {
  final Function(MMediaTrack track)? onUpload;

  const MediaUploadListTile({
    super.key,
    this.onUpload,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickedFile = useState<XFile?>(null);
    final isUploading = useState<bool>(false);
    final uploadProgress = useState<double>(0);
    final uploadedTracks = useState<List<MMediaTrack>>([]);

    startUpload() async {
      if (pickedFile.value == null) return;

      isUploading.value = true;

      final cmsApi = ref.read(cmsApiProvider);
      final result = await cmsApi.uploadMediaFile(pickedFile.value!,
          onProgress: (sent, total) {
        uploadProgress.value = sent / total;
      });

      isUploading.value = false;
      uploadedTracks.value = uploadedTracks.value..addAll(result);
      onUpload?.call(result.first);
      print(uploadedTracks.value);
    }

    onPickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.audio,
      );

      if (result != null) {
        final file = result.files.single;
        pickedFile.value = XFile(file.name, bytes: file.bytes, name: file.name);
        startUpload();
      } else {
        // User cancelled
      }
    }

    if (pickedFile.value == null) {
      return ListTile(
        dense: true,
        leading: const Icon(Icons.upload_file),
        title: const Text('Upload Media'),
        onTap: onPickFile,
      );
    }

    if (isUploading.value) {
      return ListTile(
        dense: true,
        leading: const Icon(Icons.upload_file),
        title: const Text('Uploading...'),
        subtitle: LinearProgressIndicator(
          value: uploadProgress.value,
        ),
      );
    }

    return ListTile(
      dense: true,
      leading: const Icon(Icons.check_circle),
      title: Text(pickedFile.value!.name),
      subtitle: Text(
        '${uploadedTracks.value.length} Tracks Uploaded',
      ),
    );
  }
}

// class AGContentEditor extends HookConsumerWidget {
//   const AGContentEditor({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final config = ref.watch(agTouchpointConfigProvider);
//     if (config == null) return const SizedBox();

//     return ContentNavWidget(
//       title: const Text("Content"),
//     );

//     // buildContentList() {
//     //   final selectedId = ref.watch(selectedAGContentIdProvider);
//     //   return SizedBox(
//     //     height: 200,
//     //     child: ListView.builder(
//     //       itemCount: config.contents.length,
//     //       itemBuilder: (context, index) {
//     //         final content = config.contents[index];
//     //         final isSelected = content.id == selectedId;
//     //         return ListTile(
//     //           dense: true,
//     //           selectedTileColor:
//     //               Theme.of(context).colorScheme.secondaryContainer,
//     //           selectedColor: Theme.of(context).colorScheme.onSecondaryContainer,
//     //           title: Text(
//     //             content.label ?? 'Untitled',
//     //             style: Theme.of(context).textTheme.labelLarge?.copyWith(
//     //                   fontWeight:
//     //                       isSelected ? FontWeight.w600 : FontWeight.normal,
//     //                 ),
//     //           ),
//     //           trailing: Text(
//     //             content.language?.toUpperCase() ?? '?',
//     //             style: Theme.of(context).textTheme.titleSmall,
//     //           ),
//     //           selected: isSelected,
//     //           onTap: () {},
//     //         );
//     //       },
//     //     ),
//     //   );
//     // }

//     // final selectedContent = ref.watch(aGContentEditorProvider);
//     // final labelField = ref.watch(aGContentLabelFieldProvider);
//     // final languageField = ref.watch(aGContentLanguageFieldProvider);

//     // return selectedContent.maybeWhen(
//     //   data: (content) => Container(
//     //     height: 800,
//     //     child: ContentNavWidget(
//     //       title: const Text('Content'),
//     //       child: Column(
//     //         mainAxisSize: MainAxisSize.min,
//     //         children: [
//     //           SizedBox(
//     //             height: 200,
//     //             child: Padding(
//     //               padding: const EdgeInsets.all(8.0),
//     //               child: AGContentPreview(
//     //                 content: content,
//     //               ),
//     //             ),
//     //           ),
//     //           Padding(
//     //             padding: const EdgeInsets.all(8.0),
//     //             child: InteractivePropertyTextField(
//     //               labelText: 'Label',
//     //               initialValue: labelField.valueOrNull,
//     //               loading: labelField.isLoading,
//     //               error: labelField.error?.toString(),
//     //               onSave: (value) async {
//     //                 ref
//     //                     .read(aGContentLabelFieldProvider.notifier)
//     //                     .updateValue(value);
//     //               },
//     //             ),
//     //           ),
//     //           Padding(
//     //             padding: const EdgeInsets.all(8.0),
//     //             child: InteractivePropertyDropdownField(
//     //               labelText: 'Label',
//     //               initialValue: languageField.valueOrNull ?? 'de',
//     //               loading: languageField.isLoading,
//     //               items: const [
//     //                 DropdownMenuItem(
//     //                   value: 'de',
//     //                   child: Text('German'),
//     //                 ),
//     //                 DropdownMenuItem(
//     //                   value: 'en',
//     //                   child: Text('English'),
//     //                 ),
//     //                 DropdownMenuItem(
//     //                   value: 'fr',
//     //                   child: Text('French'),
//     //                 ),
//     //               ],
//     //               onSave: (value) async {
//     //                 ref
//     //                     .read(aGContentLanguageFieldProvider.notifier)
//     //                     .updateValue(value);
//     //               },
//     //             ),
//     //           ),
//     //           Padding(
//     //             padding: const EdgeInsets.all(16.0),
//     //             child: MediaTrackField(
//     //               label: 'Audio',
//     //               trackId: content.mediaTrackId,
//     //               onUpload: (track) async {
//     //                 ref
//     //                     .read(aGContentEditorProvider.notifier)
//     //                     .updateContent(mediaTrackId: track.id);
//     //               },
//     //             ),
//     //           ),
//     //           buildContentList(),
//     //         ],
//     //       ),
//     //     ),
//     //   ),
//     //   orElse: () => const SizedBox.shrink(),
//     // );
//   }
// }

// class MediaTrackField extends ConsumerStatefulWidget {
//   const MediaTrackField({
//     super.key,
//     this.label,
//     this.trackId,
//     this.onUpload,
//   });

//   final String? label;

//   final int? trackId;

//   final void Function(MMediaTrack track)? onUpload;

//   @override
//   ConsumerState<MediaTrackField> createState() => _MediaTrackFieldState();
// }

// class _MediaTrackFieldState extends ConsumerState<MediaTrackField> {
//   MMediaTrack? _track;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.trackId != null) {
//       _loadMediaTrack(widget.trackId!);
//     }
//   }

//   @override
//   void didUpdateWidget(covariant MediaTrackField oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.trackId != widget.trackId) {
//       if (widget.trackId != null) {
//         _loadMediaTrack(widget.trackId!);
//       } else {
//         setState(() {
//           _track = null;
//         });
//       }
//     }
//   }

//   void _loadMediaTrack(int trackId) async {
//     // Load Track
//     setState(() {
//       _isLoading = true;
//     });

//     final cmsApi = ref.read(cmsApiProvider);
//     final track = await cmsApi.getMediaTrack(trackId);

//     setState(() {
//       _track = track;
//       _isLoading = false;
//     });
//   }

//   void _onEdit() async {
//     final result = await showDialog<MMediaTrack>(
//       context: context,
//       builder: (context) => const MediaUploadDialog(),
//     );

//     if (result != null) {
//       widget.onUpload?.call(result);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const LinearProgressIndicator();
//     }

//     if (_track == null) {
//       // Create
//       return TextButton(
//         onPressed: _onEdit,
//         child: const Center(child: Text('Add Media')),
//       );
//     }

//     // Preview / Edit
//     if (_track != null) {
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(widget.label ?? 'Media',
//               style: Theme.of(context).textTheme.titleSmall),
//           const SizedBox(height: 8),
//           if (_track!.type == MediaType.audio && _track!.previewUrl != null)
//             InlineAudioPlayer(
//               url: "/${_track!.previewUrl!}",
//             ),
//           const SizedBox(height: 8),
//           // Text(
//           //   _track!.filename ?? '',
//           //   overflow: TextOverflow.ellipsis,
//           // ),
//           // const SizedBox(height: 8),
//           TextButton(
//             onPressed: _onEdit,
//             child: const Center(child: Text('Change Media')),
//           ),
//         ],
//       );
//     }
//     return const SizedBox();
//   }
// }
