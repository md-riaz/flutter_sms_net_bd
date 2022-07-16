import 'package:flutter/material.dart';
import 'package:sms_net_bd/widgets/app_bar.dart';
import 'package:sms_net_bd/widgets/app_drawer.dart';

class PhonebookScreen extends StatefulWidget {
  const PhonebookScreen({Key? key}) : super(key: key);

  @override
  State<PhonebookScreen> createState() => _PhonebookScreenState();
}

class _PhonebookScreenState extends State<PhonebookScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        title: 'PhonebookScreen',
        mounted: mounted,
      ),
      drawer: appDrawer(context),
      body: const Center(
        child: Text('PhonebookScreen'),
      ),
    );
  }
}
