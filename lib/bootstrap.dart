import 'package:dio/dio.dart';
import 'package:enter_cms_flutter/api/auth_api.dart';
import 'package:enter_cms_flutter/api/cms_api.dart';
import 'package:enter_cms_flutter/api/content_api.dart';
import 'package:enter_cms_flutter/api/location_api.dart';
import 'package:enter_cms_flutter/api/media_api.dart';
import 'package:enter_cms_flutter/api/mock/media_mock_api.dart';
import 'package:enter_cms_flutter/api/rest/auth_rest_api.dart';
import 'package:enter_cms_flutter/api/rest/cms_rest_api.dart';
import 'package:enter_cms_flutter/api/rest/content_rest_api.dart';
import 'package:enter_cms_flutter/api/rest/location_rest_api.dart';
import 'package:enter_cms_flutter/application.dart';
import 'package:enter_cms_flutter/bloc/ag_content_preview/ag_content_preview_bloc.dart';
import 'package:enter_cms_flutter/bloc/auth/auth_bloc.dart';
import 'package:enter_cms_flutter/bloc/bloc_delegate.dart';
import 'package:enter_cms_flutter/services/asset_loader.dart';
import 'package:enter_cms_flutter/services/local_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

GetIt getIt = GetIt.instance;

Future<void> startApplication() async {
  final log = Logger('startApplication');

  // Configure Logger
  Logger.root.onRecord.listen((LogRecord rec) {
    // ignore: avoid_print
    print(
        '${rec.level.name[0]}: ${rec.loggerName}: ${rec.time}: ${rec.message}');
    if (rec.error != null) {
      // ignore: avoid_print
      print(
          '${rec.level.name[0]}: ${rec.loggerName}: ${rec.time}: ${rec.error}');
    }
    if (rec.stackTrace != null) {
      // ignore: avoid_print
      print(
          '${rec.level.name[0]}: ${rec.loggerName}: ${rec.time}: ${rec.stackTrace}');
    }
  });

  Bloc.observer = LoggingBlocDelegate();

  final prefs = LocalPreferencesService.instance;
  await prefs.init();

  final dio = Dio();
  dio.options.responseType = ResponseType.json;
  dio.options.baseUrl = 'http://localhost:8000/';

  getIt.registerSingleton<Dio>(dio);

  getIt.registerLazySingleton<CmsApi>(
          () => CmsRestApi(dio: dio),
  );

  getIt.registerLazySingleton<ContentApi>(
    () => ContentRestApi(dio: dio),
  );

  getIt.registerLazySingleton<MediaApi>(
    () => MediaMockApi(),
  );

  final authApi = AuthRestApi(dio: dio);
  getIt.registerSingleton<AuthApi>(authApi);

  final locationApi = LocationRestApi(dio: dio);
  getIt.registerSingleton<LocationApi>(locationApi);

  final authBloc = AuthBloc(
    authApi: authApi,
    prefsService: prefs,
  );
  authBloc.add(const AuthInit());
  getIt.registerSingleton<AuthBloc>(authBloc, dispose: (bloc) => bloc.close());

  getIt.registerLazySingleton<AgContentPreviewBloc>(() {
    final agContentPreviewBloc =
        AgContentPreviewBloc(assetLoaderService: AssetLoaderService());
    agContentPreviewBloc.add(const AgContentPreviewEventLoad());
    return agContentPreviewBloc;
  }, dispose: (bloc) => bloc.close());

  usePathUrlStrategy();

  const appLauncher = ApplicationLauncher(
    application: EnterCmsApplication(),
  );

  runApp(appLauncher);
}

class ApplicationLauncher extends StatefulWidget {
  const ApplicationLauncher({
    Key? key,
    required this.application,
  }) : super(key: key);

  final Widget application;

  @override
  State<ApplicationLauncher> createState() => _ApplicationLauncherState();
}

class _ApplicationLauncherState extends State<ApplicationLauncher> {
  @override
  Widget build(BuildContext context) {
    return widget.application;
  }
}
