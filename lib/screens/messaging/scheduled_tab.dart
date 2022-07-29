// scheduled sms
import 'package:flutter/material.dart';

class ScheduledTab extends StatefulWidget {
  const ScheduledTab({Key? key}) : super(key: key);

  @override
  State<ScheduledTab> createState() => _ScheduledTabState();
}

class _ScheduledTabState extends State<ScheduledTab> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Scheduled tab state'),
    );
  }
}
