import 'dart:async';

import 'package:enter_cms_flutter/bloc/auth/auth_bloc.dart';
import 'package:enter_cms_flutter/layouts/base.dart';
import 'package:enter_cms_flutter/routes/devices.dart';
import 'package:enter_cms_flutter/routes/home.dart';
import 'package:enter_cms_flutter/routes/login.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

final GetIt getIt = GetIt.instance;
final authBloc = getIt<AuthBloc>();

final log = Logger('router');

final router = GoRouter(
  routes: [
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
          builder: (context, state) {
            final floorplanId = state.queryParametersAll['f']?.first;
            final touchpointId = state.queryParametersAll['t']?.first;
            return ContentScreen(
              floorplanId: int.tryParse(floorplanId ?? ''),
              touchpointId: int.tryParse(touchpointId ?? ''),
            );
          },
        ),
        GoRoute(
          path: '/devices',
          builder: (context, state) => const DevicesPage(),
        ),
      ],
    ),
  ],
  redirect: (context, state) async {
    log.fine('Going to ${state.location}, query: ${state.queryParams}, all: ${state.queryParametersAll}');
    final loggedIn = authBloc.state is AuthSuccess;
    final loggingIn = state.subloc == '/login';

    // bundle the location the user is coming from into a query parameter
    final fromp = state.subloc == '/' ? '' : '?from=${state.location.replaceAll('&','\$')}';
    if (!loggedIn) return loggingIn ? null : '/login$fromp';

    // if the user is logged in, send them where they were going before (or
    // home if they weren't going anywhere)
    if (loggingIn) return state.queryParams['from']?.replaceAll('\$', '&') ?? '/';

    // no need to redirect at all
    return null;
  },
  refreshListenable: GoRouterRefreshStream(authBloc.stream),
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}