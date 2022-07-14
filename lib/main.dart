import 'package:flutter/material.dart';
import 'package:sms_net_bd/screens/login.dart';
import 'package:sms_net_bd/screens/register.dart';
import 'package:sms_net_bd/screens/splash.dart';

void main() {
  runApp(MaterialApp(
    title: 'Alpha SMS',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const SplashScreen(),
    routes: {
      '/login/': (context) => const LoginScreen(),
      '/register/': (context) => const RegisterScreen(),
    },
  ));
}
