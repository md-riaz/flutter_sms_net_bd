import 'package:flutter/material.dart';

class RadioGroup extends StatefulWidget {
  final List<Map> radioButtonValues;
  final String? defaultSelected;
  final String label;
  final Function(String) notifyParent;

  const RadioGroup(
      {Key? key,
      required this.radioButtonValues,
      this.defaultSelected,
      required this.notifyParent,
      required this.label})
      : super(key: key);

  @override
  State<RadioGroup> createState() => _RadioGroupState();
}

class _RadioGroupState extends State<RadioGroup> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.defaultSelected!;
  }

  void _handleRadioValueChange(String? value) {
    setState(() {
      selectedValue = value!;
      widget.notifyParent(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        Row(
          children: widget.radioButtonValues.map(
            (item) {
              return Expanded(
                child: RadioListTile<String>(
                  contentPadding: const EdgeInsets.all(0),
                  value: item['value'],
                  groupValue: selectedValue,
                  onChanged: _handleRadioValueChange,
                  title: Text(item['label']),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}
