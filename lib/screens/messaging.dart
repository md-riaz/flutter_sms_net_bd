import 'package:flutter/material.dart';
import 'package:sms_net_bd/widgets/app_bar.dart';
import 'package:sms_net_bd/widgets/app_drawer.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({Key? key}) : super(key: key);

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        title: 'Messaging',
        mounted: mounted,
      ),
      drawer: appDrawer(context),
      body: const Center(
        child: Text('Messaging'),
      ),
    );
  }
}
