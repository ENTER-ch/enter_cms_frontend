import 'package:enter_cms_flutter/components/enter_logo.dart';
import 'package:enter_cms_flutter/components/user_menu.dart';
import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  static const double _toolbarHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _toolbarHeight,
      title: _buildTitle(context),
      actions: const [
        UserMenu(),
        SizedBox(width: 4),
      ],
      centerTitle: false,
      titleSpacing: 8,
    );
  }

  Widget _buildTitle(BuildContext context) => Row(
        children: [
          EnterLogo(
            height: _toolbarHeight / 2,
            color: Theme.of(context).primaryTextTheme.titleMedium?.color,
          ),
          const SizedBox(width: 16),
          Text(
            'CMS',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).primaryTextTheme.titleMedium?.color,
                ),
          ),
        ],
      );

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);
}
