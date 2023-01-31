import 'package:enter_cms_flutter/components/main_app_bar.dart';
import 'package:enter_cms_flutter/components/main_nav_rail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseLayout extends StatelessWidget {
  const BaseLayout({
    Key? key,
    this.body,
    this.routerState,
  }) : super(key: key);

  final GoRouterState? routerState;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Row(
        children: [
          if (routerState != null)
            MainNavigationRail(routerState: routerState!),
          const VerticalDivider(),
          if (body != null) Expanded(child: body!),
        ],
      ),
    );
  }
}
