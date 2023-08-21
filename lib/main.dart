import 'package:enter_cms_flutter/application.dart';
import 'package:enter_cms_flutter/providers/services/shared_preferences_provider.dart';
import 'package:enter_cms_flutter/utils/state_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  Logger.root.level = Level.FINEST;

  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final sharedPrefs = await SharedPreferences.getInstance();

  return runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      observers: [
        StateLogger(),
      ],
      child: const EnterCmsApplication(),
    ),
  );
}
