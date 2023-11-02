import 'package:enter_cms_flutter/models/user.dart';
import 'package:enter_cms_flutter/providers/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher_string.dart';

final GetIt getIt = GetIt.instance;

class UserMenu extends ConsumerWidget {
  const UserMenu({super.key});

  void _showUserMenuPopup(BuildContext context, MUser user) {
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
      elevation: 0,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    if (authState.hasValue && authState.value is AuthSignedIn) {
      final user = (authState.value as AuthSignedIn).user;
      return TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => _showUserMenuPopup(context, user),
          child: Text(user.fullName));
    }
    return const SizedBox.shrink();
  }
}

class UserMenuPopup extends ConsumerWidget {
  final MUser user;

  const UserMenuPopup({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 400,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(user.fullName),
            subtitle: Text("[${user.username}] ${user.email}"),
            leading: CircleAvatar(
              child: Text(user.initials),
            ),
          ),
          const Divider(
            height: 16,
          ),
          if (user.isStaff == true)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text('Admin panel'),
              trailing: const Icon(
                Icons.settings,
                size: 20,
              ),
              onTap: () async {
                await launchUrlString('/admin/');
              },
            ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: const Text('Sign out'),
            trailing: const Icon(
              Icons.logout,
              size: 20,
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}
