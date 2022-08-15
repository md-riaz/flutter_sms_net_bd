import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String content;
  final Widget? confirmButtonText;
  final Widget? cancelButtonText;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    this.confirmButtonText,
    this.cancelButtonText,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            primary: Colors.white,
            onPrimary: Colors.teal,
            padding: const EdgeInsets.all(10),
          ),
          child: cancelButtonText ?? const Text('Cancel'),
        ),
        ElevatedButton(
          child: confirmButtonText ?? const Text('Confirm'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
