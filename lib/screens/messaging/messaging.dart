import 'package:flutter/material.dart';
import 'package:sms_net_bd/screens/messaging/pages/senderid_form.dart';
import 'package:sms_net_bd/screens/messaging/pages/template_form.dart';
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

  List screens = [
    const SMSTab(),
    const SenderIdTab(),
    const ScheduledTab(),
    const TemplateTab()
  ];

  @override
  void initState() {
    super.initState();
  }

  void handleFloatingActions() async {
    if (currentIndex == 1) {
      // request for sender id page
      final bool? addSenderId = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SenderIdForm(),
          ));

      if (addSenderId == true) {
        setState(() {
          currentIndex = 0;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            currentIndex = 1;
          });
        });
      }
    } else if (currentIndex == 3) {
      // add template page
      final bool? temAdded = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const TemplateForm(title: 'Add Template')));

      if (temAdded == true) {
        // refresh templates list
        setState(() {
          currentIndex = 0;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            currentIndex = 3;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: appBar(
        context,
        title: 'Messaging',
        mounted: mounted,
      ),
      drawer: const AppDrawer(),
      body: screens[currentIndex] ?? Container(),
      floatingActionButton: (currentIndex == 0 || currentIndex == 2)
          ? null
          : FloatingActionButton(
              onPressed: handleFloatingActions,
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
