import 'package:flutter/material.dart';

class RadioGroup extends StatefulWidget {
  final List<Map> radioButtonValues;
  String selectedValue;

  RadioGroup(
      {Key? key, required this.radioButtonValues, required this.selectedValue})
      : super(key: key);

  @override
  State<RadioGroup> createState() => _RadioGroupState();
}

class _RadioGroupState extends State<RadioGroup> {
// _handleRadioValueChange is a callback function that is called when the user selects a radio button.
  _handleRadioValueChange(String? value) {
    setState(() {
      widget.selectedValue = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Schedule SMS'),
        ListTile(
          leading: Radio<String>(
            value: '0',
            groupValue: widget.selectedValue,
            onChanged: _handleRadioValueChange,
          ),
          title: const Text('Male'),
        ),
        ListTile(
          leading: Radio<String>(
            value: '1',
            groupValue: widget.selectedValue,
            onChanged: _handleRadioValueChange,
          ),
          title: const Text('Female'),
        ),
      ],
    );
  }
}
