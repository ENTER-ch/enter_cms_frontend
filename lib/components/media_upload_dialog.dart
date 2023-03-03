import 'package:cross_file/cross_file.dart';
import 'package:enter_cms_flutter/api/media_api.dart';
import 'package:enter_cms_flutter/models/media_file.dart';
import 'package:enter_cms_flutter/models/media_track.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

final GetIt getIt = GetIt.instance;

class MediaUploadResult {
  const MediaUploadResult({
    required this.file,
    this.streamId,
  });

  final MMediaFile file;
  final int? streamId;
}

class MediaUploadDialog extends StatefulWidget {
  const MediaUploadDialog({Key? key}) : super(key: key);

  @override
  State<MediaUploadDialog> createState() => _MediaUploadDialogState();
}

class _MediaUploadDialogState extends State<MediaUploadDialog> {
  final _logger = Logger('MediaUploadDialog');
  final _mediaApi = getIt<MediaApi>();
  get _canPop => false;

  XFile? _pickedFile;

  bool _uploading = false;
  double _uploadProgress = 0.0;

  MMediaFile? _uploadedFile;

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

    final result = await _mediaApi.uploadFile(_pickedFile!, onProgress: (sent, total) {
      _logger.info("Upload progress: $sent/$total");
      setState(() {
        _uploadProgress = sent / total;
      });
    });

    setState(() {
      _uploading = false;
      _uploadedFile = result;
    });
    _onUploaded();
  }

  void _onUploaded() {
    if (_uploadedFile != null) {
      if (_uploadedFile!.mediaInfo?['streams']?.length == 1) {
        Navigator.of(context).pop(MediaUploadResult(
          file: _uploadedFile!,
          streamId: 0,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _canPop,
      child: AlertDialog(
        title: const Text('Upload Media'),
        content: SizedBox(
          width: 400,
          height: 200,
          child: _buildBody(),
        ),
        actions: [
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
    if (_uploadedFile != null) {

    }
    return const SizedBox();
  }
}
