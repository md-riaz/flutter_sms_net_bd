// templates tab
import 'package:flutter/material.dart';

class TemplateTab extends StatefulWidget {
  const TemplateTab({Key? key}) : super(key: key);

  @override
  State<TemplateTab> createState() => _TemplateTabState();
}

class _TemplateTabState extends State<TemplateTab> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('template tab'),
    );
  }
}
