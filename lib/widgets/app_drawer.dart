import 'package:flutter/material.dart';
import 'package:sms_net_bd/utils/api_client.dart';
import 'package:sms_net_bd/utils/routes.dart';

Map menu = {
  dashboardRoute: {
    'title': const Text('Dashboard'),
    'icon': const Icon(Icons.dashboard),
  },
  messagingRoute: {
    'title': const Text('Messaging'),
    'icon': const Icon(Icons.message),
  },
  phonebookRoute: {
    'title': const Text('Phonebook'),
    'icon': const Icon(Icons.contacts),
  },
  profileRoute: {
    'title': const Text('Profile'),
    'icon': const Icon(Icons.person),
  },
};

Drawer appDrawer(BuildContext context, mounted) {
  return Drawer(
    child: ListView(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.teal,
          ),
          child: Text(
            'SMS Net BD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...menu.keys.map((route) => ListTile(
              title: menu[route]?['title'],
              leading: menu[route]?['icon'],
              onTap: () {
                Navigator.of(context).pushNamed(route);
              },
            )),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Log out'),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text('Log out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            primary: Colors.white,
                            onPrimary: Colors.teal,
                            padding: const EdgeInsets.all(10),
                          ),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          child: const Text('Log out'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            logOut(context, mounted);
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute,
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ));
          },
        ),
      ],
    ),
  );
}
