import 'package:enter_cms_flutter/providers/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'routes.dart';

part 'router_listenable.g.dart';

/// A [Listenable] implemented via an [AsyncNotifier].
/// [GoRouter] accepts a [Listenable] to refresh its internal state, so this is kinda mandatory.
/// To sync Riverpod' state with this Listener, we simply accept and call a single callback on authentication change.
/// Obviously, more logic could be implemented here, this is meant to be a simple example.
///
/// I kinda like this example, as this allows to centralize global redirecting logic in one class.
///
/// SIDE NOTES.
/// This might look overcomplicated at a first glance;
/// Instead, this method aims to follow some good some good practices:
///   1. It doesn't require us to pass [Ref](s) around
///   2. It works as a complete replacement for [ChangeNotifier], as it still implements [Listenable]
///   3. It allows for listening to multiple providers, or add more logic if needed
@riverpod
class RouterListenable extends _$RouterListenable implements Listenable {
  VoidCallback? _routerListener;
  bool _isAuthenticated = false; // Useful for our global redirect function

  @override
  Future<void> build() async {
    _isAuthenticated = await ref.watch(isAuthenticatedProvider);

    ref.listenSelf((_, __) {
      if (state.isLoading) return;
      _routerListener?.call();
    });
  }

  /// Redirects the user when our authentication changes
// ignore: avoid_build_context_in_providers
  String? redirect(BuildContext context, GoRouterState state) {
    // Splash: On authed, redirect to from=, else no redirect
    // Login: On authed, redirect to from=, else no redirect
    // Unauthed: Redirect to login
    // Authed: no redirect
    if (this.state.isLoading || this.state.hasError) return null;

    final fromParam = state.uri.queryParameters['from'];
    final fromPath = fromParam != null
        ? '?from=$fromParam'
        : '?from=${Uri.encodeComponent(state.matchedLocation)}';
    final from = fromParam != null ? Uri.decodeComponent(fromParam) : null;

    final isSplash = state.matchedLocation.startsWith(SplashScreenRoute.path);
    if (isSplash) {
      final authState = ref.read(authControllerProvider);
      if (authState.isLoading) return null;
      if (_isAuthenticated) return from ?? RootRoute.path;
      return LoginRoute.path + fromPath;
    }

    final isLoggingIn = state.matchedLocation.startsWith(LoginRoute.path);
    if (isLoggingIn) {
      if (_isAuthenticated) return from ?? RootRoute.path;
      return null;
    }

    if (!_isAuthenticated) {
      return SplashScreenRoute.path + fromPath;
    }

    return null;
  }

  /// Adds [GoRouter]'s listener as specified by its [Listenable].
  /// [GoRouteInformationProvider] uses this method on creation to handle its
  /// internal [ChangeNotifier].
  /// Check out the internal implementation of [GoRouter] and
  /// [GoRouteInformationProvider] to see this in action.
  @override
  void addListener(VoidCallback listener) {
    _routerListener = listener;
  }

  /// Removes [GoRouter]'s listener as specified by its [Listenable].
  /// [GoRouteInformationProvider] uses this method when disposing,
  /// so that it removes its callback when destroyed.
  /// Check out the internal implementation of [GoRouter] and
  /// [GoRouteInformationProvider] to see this in action.
  @override
  void removeListener(VoidCallback listener) {
    _routerListener = null;
  }
}
