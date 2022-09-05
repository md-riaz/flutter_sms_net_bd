import 'package:flutter/material.dart';

class MultiSelectDialogItem<T> {
  const MultiSelectDialogItem(this.value, this.label);
  final T value;
  final String label;
}

class MultiSelectDialog<T> extends StatefulWidget {
  const MultiSelectDialog({
    Key? key,
    required this.items,
    required this.initialSelectedValues,
  }) : super(key: key);

  final List<MultiSelectDialogItem<T>> items;
  final List<T>? initialSelectedValues;

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<MultiSelectDialog<T>> {
  final _selectedValues = <T>[];

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues!);
    }
  }

  void _onItemCheckedChange(T itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select One'),
      contentPadding: const EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: const EdgeInsets.fromLTRB(14, 0, 24, 0),
          child: ListBody(
            children: widget.items.map((item) {
              final checked = _selectedValues.contains(item.value);
              return CheckboxListTile(
                value: checked,
                title: Text(item.label),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (checked) =>
                    _onItemCheckedChange(item.value, checked!),
              );
            }).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _onCancelTap,
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _onSubmitTap,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
