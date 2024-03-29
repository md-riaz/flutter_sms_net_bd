import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//todo need to have placeholder option and hint text bottom

class FormText extends StatelessWidget {
  final String label;
  final bool suggestions;
  final bool autocorrect;
  final bool obscureText;
  final AutovalidateMode? autovalidateMode;
  final bool readOnly;
  final int? maxLength;
  final int? maxLines;
  final bool bordered;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? Function(String?)? validator;
  final Function()? onTap;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final String? helperText;
  final String? errorText;
  final String? counterText;
  final Widget? counter;
  final bool? filled;
  final Color? fillColor;
  final bool? enabled;

  const FormText({
    Key? key,
    required this.label,
    this.controller,
    this.suggestions = true,
    this.autocorrect = true,
    this.obscureText = false,
    this.readOnly = false,
    this.initialValue,
    this.keyboardType,
    this.hintText,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.bordered = false,
    this.onTap,
    this.onChanged,
    this.suffixIcon,
    this.autovalidateMode,
    this.helperText,
    this.errorText,
    this.counterText,
    this.counter,
    this.filled,
    this.fillColor,
    this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller != null && initialValue != null) {
      controller?.text = initialValue!;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        autocorrect: autocorrect,
        obscureText: obscureText,
        readOnly: readOnly,
        maxLength: maxLength,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        autovalidateMode: autovalidateMode,
        onTap: onTap,
        decoration: InputDecoration(
          enabled: enabled ?? true,
          labelText: label,
          hintText: hintText,
          border: bordered ? const OutlineInputBorder() : null,
          suffixIcon: suffixIcon,
          helperText: helperText,
          helperMaxLines: 3,
          errorText: errorText,
          counterText: counterText,
          counter: counter,
          filled: filled,
          fillColor: fillColor,
        ),
        initialValue: controller == null ? initialValue : null,
        onChanged: onChanged,
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
