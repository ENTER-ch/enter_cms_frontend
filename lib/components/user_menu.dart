import 'package:enter_cms_flutter/bloc/auth/auth_bloc.dart';
import 'package:enter_cms_flutter/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:html' as html;

final GetIt getIt = GetIt.instance;

class UserMenu extends StatefulWidget {
  const UserMenu({Key? key}) : super(key: key);

  @override
  State<UserMenu> createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  final _authBloc = getIt<AuthBloc>();

  void _showUserMenuPopup(MUser user) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + size.height,
      offset.dx + size.width,
      offset.dy,
    );
    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: UserMenuPopup(user: user),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: _authBloc,
      builder: (context, state) {
        if (state is AuthSuccess && state.user != null) {
          final user = state.user!;
          return TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => _showUserMenuPopup(user),
              child: Text(user.fullName));
        }
        return const SizedBox();
      },
    );
  }
}

class UserMenuPopup extends StatelessWidget {
  final MUser user;

  const UserMenuPopup({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        children: [
          ListTile(
            title: Text(user.fullName),
            subtitle: Text("[${user.username}] ${user.email}"),
            leading: CircleAvatar(
              child: Text(user.initials),
            ),
          ),
          const Divider(height: 16,),
          if (user.isStaff == true) ListTile(
            title: const Text('Admin panel'),
            trailing: const Icon(Icons.settings, size: 20,),
            onTap: () async {
              await launchUrlString('${html.window.location.origin}/admin/');
            },
          ),
          ListTile(
            title: const Text('Sign out'),
            trailing: const Icon(Icons.logout, size: 20,),
            onTap: () {
              Navigator.pop(context);
              getIt<AuthBloc>().add(const AuthLogout());
              context.go('/');
            },
          ),
        ],
      ),
    );
  }
}
