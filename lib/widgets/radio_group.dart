import 'package:flutter/material.dart';

class RadioGroup extends StatefulWidget {
  final List<Map> radioButtonValues;
  String selectedValue;
  final Function(String) notifyParent;

  RadioGroup(
      {Key? key,
      required this.radioButtonValues,
      required this.selectedValue,
      required this.notifyParent})
      : super(key: key);

  @override
  State<RadioGroup> createState() => _RadioGroupState();
}

class _RadioGroupState extends State<RadioGroup> {
// _handleRadioValueChange is a callback function that is called when the user selects a radio button.
  void _handleRadioValueChange(String? value) {
    setState(() {
      widget.selectedValue = value!;
      widget.notifyParent(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.radioButtonValues.map(
        (item) {
          return Row(
            children: <Widget>[
              Flexible(
                child: RadioListTile<String>(
                  value: item['value'],
                  groupValue: widget.selectedValue,
                  onChanged: _handleRadioValueChange,
                  title: Text(item['label']),
                ),
              ),
            ],
          );
        },
      ).toList(),
    );
  }
}
