import 'package:flutter/material.dart';

class SenderIdDropdown extends StatefulWidget {
  const SenderIdDropdown({Key? key, required this.senderIdDropdown})
      : super(key: key);

  final List senderIdDropdown;

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
            onChanged: (dynamic val) {
              setState(() => selectedItem = val);
            },
            items: dropdownItems,
            hint: const Text('Default'),
          ),
        ],
      ),
    );
  }
}
