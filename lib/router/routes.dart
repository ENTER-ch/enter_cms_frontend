import 'dart:async';

import 'package:enter_cms_flutter/layouts/base.dart';
import 'package:enter_cms_flutter/pages/beacons_page.dart';
import 'package:enter_cms_flutter/pages/content/content_page.dart';
import 'package:enter_cms_flutter/pages/devices.dart';
import 'package:enter_cms_flutter/pages/login.dart';
import 'package:enter_cms_flutter/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

@TypedGoRoute<RootRoute>(path: RootRoute.path)
class RootRoute extends GoRouteData {
  const RootRoute();

  static const path = '/';

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    return '/content';
  }
}

@TypedGoRoute<SplashScreenRoute>(path: SplashScreenRoute.path)
class SplashScreenRoute extends GoRouteData {
  const SplashScreenRoute();

  static const path = '/splash';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashScreen();
  }
}

@TypedGoRoute<LoginRoute>(path: LoginRoute.path)
class LoginRoute extends GoRouteData {
  const LoginRoute();

  static const path = '/login';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LoginScreen();
  }
}

@TypedShellRoute<HomeRoute>(
  routes: [
    TypedGoRoute<ContentRoute>(
      path: ContentRoute.path,
      name: ContentRoute.name,
    ),
    TypedGoRoute<ContentRouteWithFloorplan>(
      path: ContentRouteWithFloorplan.path,
      name: ContentRouteWithFloorplan.name,
    ),
    TypedGoRoute<BeaconsRoute>(
      path: BeaconsRoute.path,
      name: BeaconsRoute.name,
    ),
    TypedGoRoute<DevicesRoute>(path: DevicesRoute.path),
  ],
)
class HomeRoute extends ShellRouteData {
  const HomeRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return BaseLayout(routerState: state, child: navigator);
  }
}

class ContentRoute extends GoRouteData {
  const ContentRoute();

  static const path = '/content';
  static const name = 'content';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ContentPageLoader();
  }
}

class ContentRouteWithFloorplan extends GoRouteData {
  final String floorplanId;

  const ContentRouteWithFloorplan({
    required this.floorplanId,
  });

  static const path = '/content/:floorplanId';
  static const name = 'content-floorplan';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ContentPageLoader(
      floorplanId: floorplanId,
    );
  }
}

class BeaconsRoute extends GoRouteData {
  const BeaconsRoute();

  static const path = '/beacons';
  static const name = 'beacons';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BeaconsPage();
  }
}

class DevicesRoute extends GoRouteData {
  const DevicesRoute();

  static const path = '/devices';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DevicesPage();
  }
}
