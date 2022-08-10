import 'package:flutter/material.dart';
import 'package:sms_net_bd/screens/messaging/scheduled_tab.dart';
import 'package:sms_net_bd/screens/messaging/senderid_tab.dart';
import 'package:sms_net_bd/screens/messaging/sms_tab.dart';
import 'package:sms_net_bd/screens/messaging/templates_tab.dart';
import 'package:sms_net_bd/screens/messaging/widgets/bottom_nav.dart';
import 'package:sms_net_bd/widgets/app_bar.dart';
import 'package:sms_net_bd/widgets/app_drawer.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({Key? key}) : super(key: key);

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  int currentIndex = 0;

  final List<StatefulWidget> screens = [
    const SMSTab(),
    const SenderIdTab(),
    const ScheduledTab(),
    const TemplateTab()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: appBar(
        context,
        title: 'Messaging',
        mounted: mounted,
      ),
      drawer: appDrawer(context),
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
