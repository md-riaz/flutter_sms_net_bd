import 'package:flutter/material.dart';
import 'package:sms_net_bd/screens/messaging/pages/add_template.dart';
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
      drawer: appDrawer(context, mounted),
      body: screens[currentIndex],
      floatingActionButton: (currentIndex == 0 || currentIndex == 2)
          ? null
          : FloatingActionButton(
              onPressed: () {
                if (currentIndex == 1) {
                  // request for sender id page
                } else if (currentIndex == 3) {
                  // add template page
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const AddTemplate();
                  }));
                }
              },
              tooltip: 'Increment',
              elevation: 2.0,
              child: const Icon(Icons.add),
            ),
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
