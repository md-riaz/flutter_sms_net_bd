import 'package:sms_net_bd/screens/dashboard.dart';
import 'package:sms_net_bd/screens/login.dart';
import 'package:sms_net_bd/screens/splash.dart';

class Routes {
  static list() {
    return {
      '/': (context) => const SplashScreen(),
      '/login/': (context) => const LoginScreen(),
      '/dashboard/': (context) => const DashboardScreen(),
    };
  }

  static initScreen() {
    return '/';
  }
}
