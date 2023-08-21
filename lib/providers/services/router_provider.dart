import 'package:enter_cms_flutter/router/router_listenable.dart';
import 'package:enter_cms_flutter/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router_provider.g.dart';

@riverpod
Raw<GoRouter> router(RouterRef ref) {
  final notifier = ref.watch(routerListenableProvider.notifier);
  final key = GlobalKey<NavigatorState>(debugLabel: 'routerKey');
  final router = GoRouter(
    navigatorKey: key,
    refreshListenable: notifier,
    initialLocation: SplashScreenRoute.path,
    debugLogDiagnostics: true,
    routes: $appRoutes,
    redirect: notifier.redirect,
  );

  ref.onDispose(router.dispose);

  return router;
}
