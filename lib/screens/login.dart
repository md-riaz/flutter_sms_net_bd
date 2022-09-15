import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sms_net_bd/utils/api_client.dart';
import 'package:sms_net_bd/utils/authentication.dart';
import 'package:sms_net_bd/widgets/error_dialog.dart';
import 'package:sms_net_bd/widgets/form_text.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _passwordVisible = false;
  late final TextEditingController _email;
  late final TextEditingController _password;

  // biometric authentication
  bool? _wantsTouchId = false;
  final LocalAuthentication _auth = LocalAuthentication();
  final storage = const FlutterSecureStorage();
  bool canUseBiometrics = false;
  bool isFingerprintSet = false;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    isBiometricAvailable();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(top: 100),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // add logo image here
                Image.asset(
                  'assets/images/light_logo.png',
                  height: 100,
                  width: 300,
                ),
                FormText(
                  controller: _email,
                  suggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  label: 'Email',
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!val.isEmail) {
                      return 'Please enter a valid email';
                    }

                    return null;
                  },
                ),
                FormText(
                  controller: _password,
                  obscureText: !_passwordVisible,
                  suggestions: false,
                  autocorrect: false,
                  label: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                if (canUseBiometrics && !isFingerprintSet)
                  CheckboxListTile(
                    title: const Text('Touch ID Login'),
                    value: _wantsTouchId,
                    onChanged: (bool? val) {
                      setState(() {
                        _wantsTouchId = val ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_isLoading && _formKey.currentState!.validate()) {
                          await initLogin(_email.text, _password.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: _isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),
                  ),
                ),
                if (isFingerprintSet)
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: const Text(
                          'OR',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      InkWell(
                        onTap: handleFingerprintLogin,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.teal,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: const Icon(
                            Icons.fingerprint,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                TextButton(
                  onPressed: () {
                    final Uri url = Uri.parse('https://sms.net.bd/signup/');
                    _launchUrl(url); // Launch the URL.
                  },
                  child: const Text('Not registered yet? Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> isBiometricAvailable() async {
    bool isAvailable = false;
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final bool canAuthenticateWithBiometrics =
            await _auth.canCheckBiometrics;
        final bool isDeviceSupported = await _auth.isDeviceSupported();

        if (canAuthenticateWithBiometrics && isDeviceSupported) {
          isAvailable = true;
        }
      } catch (e) {
        isAvailable = false;
      } finally {
        final usingBiometric = await storage.read(key: 'usingBiometric');

        if (mounted) {
          setState(() {
            canUseBiometrics = isAvailable;
            isFingerprintSet = (usingBiometric == 'true') ? true : false;
          });
        }
      }
    }
  }

  Future<void> initLogin(email, password) async {
    setState(() {
      _isLoading = true;
    });

    // fingerPrintLogin

    if (_wantsTouchId == true && canUseBiometrics) {
      bool isAuthenticated =
          await Authentication.authenticateWithBiometrics(context);

      if (isAuthenticated) {
        storage.write(
          key: 'usingBiometric',
          value: _wantsTouchId.toString(),
        );

        storage.write(
          key: 'credentials',
          value: base64Encode(utf8.encode('${_email.text}:${_password.text}')),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    try {
      final result = await sendRequest(
        context: context,
        mounted: mounted,
        uri: '/user/login/',
        type: 'POST',
        body: {'email': email, 'password': password},
      );

      if (result['error'] == 0) {
        // Store the user data in shared preferences.
        await addToken(result);
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/dashboard/');
      } else {
        if (!mounted) return;

        await showErrorDialog(
          context,
          result['msg'],
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    return;
  }

  Future<void> handleFingerprintLogin() async {
    bool isAuthenticated =
        await Authentication.authenticateWithBiometrics(context);

    if (isAuthenticated) {
      String? credentials = await storage.read(key: 'credentials');

      credentials = utf8.decode(base64Decode(credentials!));

      final email = credentials.split(':')[0];
      final password = credentials.split(':')[1];

      initLogin(email, password);
    }
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}
