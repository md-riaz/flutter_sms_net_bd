import 'package:flutter/material.dart';

class TemplateDropdown extends StatefulWidget {
  const TemplateDropdown(
      {Key? key, required this.templateItems, required this.notifyParent})
      : super(key: key);

  final List templateItems;
  final Function(dynamic) notifyParent;

  @override
  State<TemplateDropdown> createState() => _TemplateDropdownState();
}

class _TemplateDropdownState extends State<TemplateDropdown> {
  String? selectedItem;
  List<DropdownMenuItem> dropdownItems = [];

  buildSenderIdDropdown(data) {
    data.forEach((item) {
      dropdownItems.add(
        DropdownMenuItem(
          value: item['text'],
          child: Text(item['name']),
        ),
      );
    });
  }

  @override
  void initState() {
    buildSenderIdDropdown(widget.templateItems);
    super.initState();
  }

  void _handleDropdownSelection(dynamic val) {
    setState(() => selectedItem = val);
    widget.notifyParent(val);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SMS Templates'),
          DropdownButtonFormField(
            value: selectedItem,
            onChanged: _handleDropdownSelection,
            items: dropdownItems,
            hint: const Text('Select a template'),
          ),
        ],
      ),
    );
  }
}
