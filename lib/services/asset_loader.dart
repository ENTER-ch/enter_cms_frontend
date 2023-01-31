import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;

class AssetLoaderService {
  static Future<Map<String, dynamic>> _loadAssetManifest() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    return json.decode(manifestContent);
  }

  static Future<ui.Image> _loadUiImage(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<Map<int, ui.Image>> loadAGPreviewAssets() async {
    final assetManifest = await _loadAssetManifest();
    final Map<int, ui.Image> assets = {};

    final assetJobs = assetManifest.keys
        // Filter for ag_gui directory
        .where((path) => path.startsWith('assets/ag_gui/'))
        .map<Future<void>>((e) async {
      final parts = e.split('/');
      final filename = parts[parts.length - 1];
      String assetDescriptor = filename.split('.')[0];

      if (assetDescriptor.length > 3) {
        // Ignore other languages
        if (assetDescriptor[3] != 'd') {
          return Future.value(null);
        }
        assetDescriptor = filename.substring(0, 3);
      }

      final assetId = int.parse(assetDescriptor);
      final assetImage = await _loadUiImage(e);

      assets[assetId] = assetImage;
    });

    await Future.wait(assetJobs);

    return assets;
  }
}
