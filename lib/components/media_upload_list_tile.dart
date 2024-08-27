import 'package:cross_file/cross_file.dart';
import 'package:enter_cms_flutter/models/media_track.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
