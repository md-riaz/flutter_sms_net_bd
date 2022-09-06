import 'package:flutter/material.dart';

List bottomBar = [
  {
    'title': 'Requests',
    'icon': const Icon(Icons.message_outlined),
  },
  {
    'title': 'Messages',
    'icon': const Icon(Icons.badge_outlined),
  },
  {
    'title': 'Transactions',
    'icon': const Icon(Icons.schedule_outlined),
  }
];

BottomNavigationBar appBottomBar(BuildContext context, currentIndex, onTab) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    type: BottomNavigationBarType.fixed,
    onTap: onTab,
    items: bottomBar
        .map((item) => BottomNavigationBarItem(
              icon: item['icon'],
              label: item['title'],
            ))
        .toList(),
  );
}
