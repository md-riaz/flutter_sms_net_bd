import 'package:flutter/material.dart';
import 'package:sms_net_bd/screens/login.dart';
import 'package:sms_net_bd/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    onUnauthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }

  void onUnauthenticated() {
    Future.delayed(const Duration(seconds: 1), () {
      return Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    });
  }
}
