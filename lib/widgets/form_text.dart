import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormText extends StatelessWidget {
  const FormText({
    Key? key,
    required this.label,
    required this.controller,
    this.suggestions = true,
    this.autocorrect = true,
    this.obscureText = false,
    this.keyboardType,
    this.hintText,
    this.validator,
    this.inputFormatters,
    this.maxLength,
  }) : super(key: key);

  final String label;
  final TextEditingController controller;
  final bool suggestions;
  final bool autocorrect;
  final bool obscureText;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        autocorrect: autocorrect,
        obscureText: obscureText,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
        ),
      ),
    );
  }
}

extension ExtString on String {
  bool get isEmail {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(this);
  }

  bool get isValidPassword {
    final passwordRegExp =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\><*~]).{8,}');
    return passwordRegExp.hasMatch(this);
  }

  bool get isPhoneNumber {
    final phoneRegExp = RegExp(r"^\+?0[0-9]{10}$");
    return phoneRegExp.hasMatch(this);
  }
}
