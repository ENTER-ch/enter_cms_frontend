import 'package:cross_file/cross_file.dart';
import 'package:enter_cms_flutter/api/media_api.dart';
import 'package:enter_cms_flutter/models/media_file.dart';
import 'package:enter_cms_flutter/models/media_track.dart';

class MediaMockApi extends MediaApi {
  static const _lagDuration = Duration(milliseconds: 250);

  List<MMediaFile> _mediaFiles = [
    MMediaFile(
      id: 1,
      name: 'Media File 1',
      type: MediaType.audio,
      mediaInfo: {
        'duration': 1000,
        'width': 1920,
        'height': 1080,
      },
      url: '/mock_data/media/ag_test_content.wav',
    ),
  ];

  List<MMediaTrack> _mediaTracks = [
    MMediaTrack(
      id: 1,
      type: MediaType.audio,
      index: 0,
      source: 1,
      filename: 'ag_test_content.wav',
      previewUrl: '/mock_data/media/ag_test_content.wav',
    ),
  ];

  @override
  Future<MMediaTrack> getMediaTrack(int id) {
    return Future.delayed(
      _lagDuration,
      () => _mediaTracks.firstWhere((track) => track.id == id),
    );
  }

  @override
  Future<MMediaTrack> createMediaTrack(MMediaTrack track) {
    final newTrack = track.copyWith(
      id: _mediaTracks.length + 1,
      previewUrl: '/mock_data/media/ag_test_content.wav',
    );
    _mediaTracks.add(newTrack);
    return Future.delayed(
      _lagDuration,
      () => newTrack,
    );
  }

  @override
  Future<MMediaTrack> updateMediaTrack(MMediaTrack track) {
    _mediaTracks.removeWhere((t) => t.id == track.id);
    _mediaTracks.add(track);
    return Future.delayed(
      _lagDuration,
      () => track,
    );
  }

  @override
  Future<Function> deleteMediaTrack(int id) {
    _mediaTracks.removeWhere((t) => t.id == id);
    return Future.delayed(
      _lagDuration,
      () => () {},
    );
  }

  @override
  Future<MMediaFile> uploadFile(XFile file, {Function(int, int)? onProgress}) async {
    for (var i = 0; i < 100; i++) {
      await Future.delayed(const Duration(milliseconds: 10));
      onProgress?.call(i, 100);
    }

    final mediaFile = MMediaFile(
      id: _mediaFiles.length + 1,
      name: file.name,
      type: MediaType.audio,
      mediaInfo: {"format": {"size": "9888", "bit_rate": "32000", "duration": "2.472000", "filename": "/var/www/django/media/raw/test.mp3", "nb_streams": 1, "start_time": "0.000000", "format_name": "mp3", "nb_programs": 0, "probe_score": 51, "format_long_name": "MP2/3 (MPEG audio layer 2/3)"}, "streams": [{"index": 0, "bit_rate": "32000", "channels": 1, "duration": "2.472000", "codec_tag": "0x0000", "start_pts": 0, "time_base": "1/14112000", "codec_name": "mp3", "codec_type": "audio", "sample_fmt": "fltp", "start_time": "0.000000", "disposition": {"dub": 0, "forced": 0, "lyrics": 0, "comment": 0, "default": 0, "karaoke": 0, "original": 0, "attached_pic": 0, "clean_effects": 0, "visual_impaired": 0, "hearing_impaired": 0, "timed_thumbnails": 0}, "duration_ts": 34884864, "sample_rate": "24000", "r_frame_rate": "0/0", "avg_frame_rate": "0/0", "channel_layout": "mono", "bits_per_sample": 0, "codec_long_name": "MP3 (MPEG audio layer 3)", "codec_time_base": "1/24000", "codec_tag_string": "[0][0][0][0]"}]},
      url: '/mock_data/media/ag_test_content.wav',
    );

    _mediaFiles.add(mediaFile);

    return Future.delayed(
      _lagDuration,
      () => mediaFile,
    );
  }
}