import 'package:enter_cms_flutter/components/enter_logo.dart';
import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({Key? key}) : super(key: key);

  static const double _toolbarHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _toolbarHeight,
      title: _buildTitle(context),
      centerTitle: false,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  Widget _buildTitle(BuildContext context) => Row(
    children: [
      EnterLogo(
        height: _toolbarHeight / 2,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      const SizedBox(width: 16),
      Text(
        'Content Management System',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    ],
  );

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);
}
