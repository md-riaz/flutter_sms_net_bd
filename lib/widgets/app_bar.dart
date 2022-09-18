import 'package:flutter/material.dart';
import 'package:sms_net_bd/utils/api_client.dart';
import 'package:sms_net_bd/utils/routes.dart';

enum MenuAction { profile, logout }

AppBar appBar(
  BuildContext context, {
  required String title,
  bool showBackButton = false,
  bool mounted = true,
}) {
  return AppBar(
    title: Text(title),
    leading: showBackButton
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          )
        : null,
    actions: [
      PopupMenuButton<MenuAction>(
        onSelected: (value) async {
          final navigation = Navigator.of(context);

          switch (value) {
            case MenuAction.logout:
              final shouldLogout = await showLogOutDialog(context);

              if (shouldLogout) {
                await removeToken();

                if (!mounted) return;

                navigation.pushNamedAndRemoveUntil(
                  loginRoute,
                  (_) => false,
                );
              }
              break;

            case MenuAction.profile:
              navigation.pushNamed(profileRoute);
              break;
          }
        },
        itemBuilder: (context) {
          return const [
            PopupMenuItem<MenuAction>(
              value: MenuAction.profile,
              child: Text('Profile'),
            ),
            PopupMenuItem<MenuAction>(
              value: MenuAction.logout,
              child: Text('Log out'),
            ),
          ];
        },
      )
    ],
  );
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Log out')),
        ],
      );
    },
  ).then((value) => value ?? false);
}
