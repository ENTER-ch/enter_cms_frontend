import 'package:dio/dio.dart';
import 'package:enter_cms_flutter/bloc/auth/auth_bloc.dart';
import 'package:enter_cms_flutter/router.dart';
import 'package:enter_cms_flutter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

class EnterCmsApplication extends StatefulWidget {
  const EnterCmsApplication({Key? key}) : super(key: key);

  @override
  State<EnterCmsApplication> createState() => _EnterCmsApplicationState();
}

class _EnterCmsApplicationState extends State<EnterCmsApplication> {
  @override
  void initState() {
    super.initState();
    registerDioInterceptors();
  }

  void registerDioInterceptors() {
    final dio = getIt<Dio>();

    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          getIt<AuthBloc>().add(const AuthLogout());
          router.go('/login');
        }
        return handler.next(error);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
