import 'package:flutter/material.dart';

class SenderIdDropdown extends StatefulWidget {
  final List senderIdDropdown;
  final Function(String) onChanged;

  const SenderIdDropdown(
      {Key? key, required this.senderIdDropdown, required this.onChanged})
      : super(key: key);

  @override
  State<SenderIdDropdown> createState() => _SenderIdDropdownState();
}

class _SenderIdDropdownState extends State<SenderIdDropdown> {
  String? selectedItem;
  List<DropdownMenuItem> dropdownItems = [];

  buildSenderIdDropdown(data) {
    dropdownItems.add(
      const DropdownMenuItem(
        value: null,
        child: Text('Default'),
      ),
    );

    data.forEach((item) {
      dropdownItems.add(
        DropdownMenuItem(
          value: item['sender_id'],
          child: Text(item['sender_id']),
        ),
      );
    });
  }

  @override
  void initState() {
    buildSenderIdDropdown(widget.senderIdDropdown);
    super.initState();
  }

  void _handleSenderIdChange(dynamic val) {
    setState(() => selectedItem = val);
    widget.onChanged(val.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sender ID'),
          DropdownButtonFormField(
            value: selectedItem,
            onChanged: _handleSenderIdChange,
            items: dropdownItems,
            hint: const Text('Default'),
          ),
        ],
      ),
    );
  }
}
