import 'package:sms_net_bd/screens/dashboard.dart';
import 'package:sms_net_bd/screens/login.dart';
import 'package:sms_net_bd/screens/splash.dart';

const String initialRoute = '/';
const String loginRoute = '/login/';
const String dashboardRoute = '/dashboard/';

class Routes {
  static list() {
    return {
      initialRoute: (context) => const SplashScreen(),
      loginRoute: (context) => const LoginScreen(),
      dashboardRoute: (context) => const DashboardScreen(),
    };
  }

  static initScreen() {
    return initialRoute;
  }
}
