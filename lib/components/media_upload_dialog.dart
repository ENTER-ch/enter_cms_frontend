import 'package:cross_file/cross_file.dart';
import 'package:enter_cms_flutter/components/inline_audio_player.dart';
import 'package:enter_cms_flutter/models/media_track.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

final GetIt getIt = GetIt.instance;

class MediaUploadDialog extends ConsumerStatefulWidget {
  const MediaUploadDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<MediaUploadDialog> createState() => _MediaUploadDialogState();
}

class _MediaUploadDialogState extends ConsumerState<MediaUploadDialog> {
  final _logger = Logger('MediaUploadDialog');

  XFile? _pickedFile;

  bool _uploading = false;
  double _uploadProgress = 0.0;

  final List<MMediaTrack> _uploadedTracks = [];

  void _onPickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.media,
    );

    if (result != null) {
      final file = result.files.single;
      _pickedFile = XFile(file.name, bytes: file.bytes, name: file.name);
      setState(() {});
      _upload();
    } else {
      _logger.info('User cancelled file picker');
    }
  }

  void _upload() async {
    setState(() {
      _uploading = true;
    });

    final cmsApi = ref.read(cmsApiProvider);
    final result =
        await cmsApi.uploadMediaFile(_pickedFile!, onProgress: (sent, total) {
      _logger.info("Upload progress: $sent/$total");
      setState(() {
        _uploadProgress = sent / total;
      });
    });

    setState(() {
      _uploading = false;
      _uploadedTracks.addAll(result);
    });
    _onUploaded();
  }

  void _onUploaded() {
    // if (_uploadedFile != null) {
    //   if (_uploadedFile!.mediaInfo?['streams']?.length == 1) {
    //     Navigator.of(context).pop(MediaUploadResult(
    //       file: _uploadedFile!,
    //       streamId: 0,
    //     ));
    //   }
    // }
  }

  Future<bool> get _canPop async {
    return !_uploading;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _canPop,
      child: AlertDialog(
        title: const Text('Upload Media'),
        content: SizedBox(
          width: 450,
          height: 400,
          child: _buildBody(),
        ),
        actions: [
          if (!_uploading)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_pickedFile == null) {
      return Center(
        child: ElevatedButton(
          onPressed: _onPickFiles,
          child: const Text("Select File"),
        ),
      );
    }
    if (_uploading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Uploading..."),
            Text(_pickedFile?.name ?? ""),
            LinearProgressIndicator(value: _uploadProgress),
          ],
        ),
      );
    }
    if (_uploadedTracks.isNotEmpty) {
      return ListView.builder(
        itemBuilder: (context, index) {
          final track = _uploadedTracks[index];
          return _buildTrackPreviewListTile(track);
        },
        itemCount: _uploadedTracks.length,
      );
    }
    return const SizedBox();
  }

  Widget _buildTrackPreviewListTile(MMediaTrack track) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          ListTile(
            leading: Icon(track.type.icon),
            title: Text("Track ${track.index + 1}"),
            trailing: Text(track.language?.toUpperCase() ?? "?"),
            onTap: () {
              Navigator.of(context).pop(track);
            },
          ),
          if (track.type == MediaType.audio && track.previewUrl != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InlineAudioPlayer(
                url: track.previewUrl!,
              ),
            ),
        ],
      ),
    );
  }
}
