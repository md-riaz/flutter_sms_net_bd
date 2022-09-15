import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';

class Authentication {
  static Future<bool> authenticateWithBiometrics(BuildContext context) async {
    final LocalAuthentication localAuthentication = LocalAuthentication();
    bool isBiometricSupported = await localAuthentication.isDeviceSupported();
    bool canCheckBiometrics = await localAuthentication.canCheckBiometrics;

    bool isAuthenticated = false;

    if (isBiometricSupported && canCheckBiometrics) {
      try {
        isAuthenticated = await localAuthentication.authenticate(
          localizedReason: 'Please complete the biometrics to proceed.',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );
      } catch (e) {
        log(e.toString());
      }
    }

    return isAuthenticated;
  }
}
