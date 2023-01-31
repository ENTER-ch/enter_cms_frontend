import 'package:dio/dio.dart';
import 'package:enter_cms_flutter/api/content_api.dart';
import 'package:enter_cms_flutter/api/mock/content_mock_api.dart';
import 'package:enter_cms_flutter/application.dart';
import 'package:enter_cms_flutter/bloc/ag_content_preview/ag_content_preview_bloc.dart';
import 'package:enter_cms_flutter/bloc/bloc_delegate.dart';
import 'package:enter_cms_flutter/services/asset_loader.dart';
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

  final dio = Dio();
  dio.options.responseType = ResponseType.json;
  dio.options.baseUrl = 'http://localhost:8000/';

  getIt.registerLazySingleton<ContentApi>(
    () => ContentMockApi(),
  );

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
