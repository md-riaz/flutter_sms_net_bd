import 'package:flutter/material.dart';

const baseAPI = 'https://api.dev.alpha.net.bd';

const appKey = 'TWWx8fSPmeG4dCGYZ93TWWx8fStXxNB8hjgjKLJH';

const preloader = Center(
  child: CircularProgressIndicator(
    color: Colors.purple,
  ),
);

extension ExtString on String {
  bool get isValidEmail {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(this);
  }

  bool get isValidPassword {
    final passwordRegExp =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\><*~]).{8,}');
    return passwordRegExp.hasMatch(this);
  }

  bool get isValidPhone {
    final phoneRegExp = RegExp(r"^\+?0[0-9]{10}$");
    return phoneRegExp.hasMatch(this);
  }
}
