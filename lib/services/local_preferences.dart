import 'dart:convert';

import 'package:enter_cms_flutter/models/token.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferencesService {
  final log = Logger('LocalPreferencesService');

  LocalPreferencesService._privateConstructor();
  static final LocalPreferencesService instance =
      LocalPreferencesService._privateConstructor();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  MToken? get token {
    final tokenJson = _prefs.getString('token');
    if (tokenJson == null) {
      return null;
    }
    return MToken.fromJson(jsonDecode(tokenJson));
  }

  set token(MToken? token) {
    if (token == null) {
      _prefs.remove('token');
    } else {
      _prefs.setString('token', jsonEncode(token.toJson()));
    }
  }
}