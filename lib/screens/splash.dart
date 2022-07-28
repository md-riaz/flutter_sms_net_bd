import 'package:flutter/material.dart';
import 'package:sms_net_bd/utils/api_client.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/utils/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }

  void checkAuth() async {
    bool auth = await checkAuthentication(context, mounted);

    if (auth) {
      return onAuthenticated();
    } else {
      return onUnauthenticated();
    }
  }

  void onUnauthenticated() {
    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);

    return;
  }

  void onAuthenticated() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(dashboardRoute, (route) => false);

    return;
  }
}
