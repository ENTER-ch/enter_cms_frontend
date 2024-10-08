import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigationRail extends StatelessWidget {
  const MainNavigationRail({
    super.key,
    required this.routerState,
  });

  final GoRouterState routerState;

  final List<GoRouterNavRailDestination> destinations = const [
    GoRouterNavRailDestination(
      path: '/content',
      label: 'Content',
      icon: Icons.library_books,
    ),
    GoRouterNavRailDestination(
      path: '/beacons',
      label: 'Beacons',
      icon: Icons.podcasts,
    ),
    GoRouterNavRailDestination(
      path: '/devices',
      label: 'Devices',
      disabled: true,
      icon: Icons.device_hub,
    ),
    // GoRouterNavRailDestination(
    //   path: '/analytics',
    //   label: 'Analytics',
    //   icon: Icons.analytics,
    // ),
  ];

  int get _selectedIndex => destinations.indexWhere(
        (destination) =>
            routerState.matchedLocation.startsWith(destination.path),
      );

  void _onDestinationSelected(BuildContext context, int index) {
    GoRouter.of(context).go(destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      labelType: NavigationRailLabelType.all,
      selectedIndex: _selectedIndex,
      destinations: destinations
          .map((e) => e.toNavigationRailDestination(context))
          .toList(),
      onDestinationSelected: (i) => _onDestinationSelected(context, i),
    );
  }
}

class GoRouterNavRailDestination {
  final String path;
  final String label;
  final IconData icon;
  final bool disabled;

  const GoRouterNavRailDestination({
    required this.path,
    required this.label,
    required this.icon,
    this.disabled = false,
  });

  NavigationRailDestination toNavigationRailDestination(BuildContext context) {
    return NavigationRailDestination(
      icon: Icon(icon),
      label: Text(label),
      disabled: disabled,
    );
  }
}
