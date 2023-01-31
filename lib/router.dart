import 'package:enter_cms_flutter/layouts/base.dart';
import 'package:enter_cms_flutter/routes/devices.dart';
import 'package:enter_cms_flutter/routes/home.dart';
import 'package:enter_cms_flutter/routes/login.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(routes: [
  GoRoute(
    path: '/',
    redirect: (context, state) => '/content',
  ),
  GoRoute(
    path: '/login',
    builder: (context, state) => const LoginView(),
  ),
  ShellRoute(
    builder: (context, state, child) => BaseLayout(
      body: child,
      routerState: state,
    ),
    routes: [
      GoRoute(
        path: '/content',
        builder: (context, state) => const ContentScreen(),
      ),
      GoRoute(
        path: '/devices',
        builder: (context, state) => const DevicesPage(),
      ),
    ],
  ),
]);
