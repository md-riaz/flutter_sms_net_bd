import 'package:flutter/material.dart';
import 'package:sms_net_bd/utils/routes.dart';

void main() {
  runApp(MaterialApp(
    title: 'Alpha SMS',
    theme: ThemeData(
      primarySwatch: Colors.teal,
    ),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.teal,
    ),
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    routes: Routes.list(),
    initialRoute: Routes.initScreen(),
  ));
}
