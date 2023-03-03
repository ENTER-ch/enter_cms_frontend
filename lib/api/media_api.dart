import 'package:cross_file/cross_file.dart';
import 'package:enter_cms_flutter/models/media_file.dart';
import 'package:enter_cms_flutter/models/media_track.dart';

abstract class MediaApi {
  Future<MMediaTrack> getMediaTrack(int id);
  Future<MMediaTrack> createMediaTrack(MMediaTrack track);
  Future<MMediaTrack> updateMediaTrack(MMediaTrack track);
  Future<void> deleteMediaTrack(int id);

  Future<MMediaFile> uploadFile(XFile file, {Function(int, int)? onProgress});
}