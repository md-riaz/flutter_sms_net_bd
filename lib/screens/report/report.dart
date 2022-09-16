import 'package:flutter/material.dart';
import 'package:sms_net_bd/screens/report/complete_messages.dart';
import 'package:sms_net_bd/screens/report/complete_requests.dart';
import 'package:sms_net_bd/screens/report/transactions.dart';
import 'package:sms_net_bd/screens/report/widgets/bottom_nav.dart';
import 'package:sms_net_bd/widgets/app_bar.dart';
import 'package:sms_net_bd/widgets/app_drawer.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int currentIndex = 0;

  List screens = [
    const CompleteRequests(),
    const CompleteMessages(),
    const Transactions()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        title: 'Reports',
        mounted: mounted,
      ),
      drawer: const AppDrawer(),
      body: screens[currentIndex],
      bottomNavigationBar: appBottomBar(
        context,
        currentIndex,
        (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
