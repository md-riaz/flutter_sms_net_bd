import 'package:sms_net_bd/screens/dashboard.dart';
import 'package:sms_net_bd/screens/login.dart';
import 'package:sms_net_bd/screens/messaging/messaging.dart';
import 'package:sms_net_bd/screens/monitor.dart';
import 'package:sms_net_bd/screens/phonebook/phonebook.dart';
import 'package:sms_net_bd/screens/profile.dart';
import 'package:sms_net_bd/screens/report/report.dart';
import 'package:sms_net_bd/screens/splash.dart';

const String initialRoute = '/';
const String loginRoute = '/login/';
const String dashboardRoute = '/dashboard/';
const String messagingRoute = '/messaging/';
const String phonebookRoute = '/phonebook/';
const String reportRoute = '/report/';
const String monitorRoute = '/monitor/';
const String profileRoute = '/profile/';

class Routes {
  static list() {
    return {
      initialRoute: (context) => const SplashScreen(),
      loginRoute: (context) => const LoginScreen(),
      dashboardRoute: (context) => const DashboardScreen(),
      messagingRoute: (context) => const MessagingScreen(),
      phonebookRoute: (context) => const PhonebookScreen(),
      reportRoute: (context) => const ReportScreen(),
      monitorRoute: (context) => const MonitorScreen(),
      profileRoute: (context) => const ProfileScreen(),
    };
  }

  static initScreen() {
    return initialRoute;
  }
}
