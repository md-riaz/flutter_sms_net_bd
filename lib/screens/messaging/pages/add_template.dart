import 'package:flutter/material.dart';

class AddTemplate extends StatefulWidget {
  const AddTemplate({Key? key}) : super(key: key);

  @override
  State<AddTemplate> createState() => _AddTemplateState();
}

class _AddTemplateState extends State<AddTemplate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Template'),
      ),
      body: const Center(
        child: Text('Add Template'),
      ),
    );
  }
}
