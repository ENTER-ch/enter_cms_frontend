import 'package:enter_cms_flutter/components/main_app_bar.dart';
import 'package:enter_cms_flutter/components/main_nav_rail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseLayout extends StatelessWidget {
  const BaseLayout({
    super.key,
    this.child,
    this.routerState,
  });

  final GoRouterState? routerState;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: Material(
        child: Row(
          children: [
            if (routerState != null)
              MainNavigationRail(routerState: routerState!),
            const VerticalDivider(),
            if (child != null) Expanded(child: child!),
          ],
        ),
      ),
    );
  }
}
