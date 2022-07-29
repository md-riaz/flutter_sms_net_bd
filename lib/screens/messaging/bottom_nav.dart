import 'package:flutter/material.dart';

List bottomBar = [
  {
    'title': 'SMS',
    'icon': const Icon(Icons.message_outlined),
  },
  {
    'title': 'Sender ID',
    'icon': const Icon(Icons.badge_outlined),
  },
  {
    'title': 'Scheduled SMS',
    'icon': const Icon(Icons.schedule_outlined),
  },
  {
    'title': 'Templates',
    'icon': const Icon(Icons.bookmark_outlined),
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
