import 'package:flutter/material.dart';

List bottomBar = [
  {
    'title': 'Contacts',
    'icon': const Icon(Icons.contacts),
  },
  {
    'title': 'Groups',
    'icon': const Icon(Icons.group),
  },
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
