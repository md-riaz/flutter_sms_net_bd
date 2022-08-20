import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:sms_net_bd/utils/api_client.dart';
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
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool? _touchId;

  @override
  void initState() {
    _email = TextEditingController(text: 'riazmd581@gmail.com');
    _password = TextEditingController(text: 'P@\$\$w0rd786*');
    super.initState();
  }

  Future<void> initLogin() async {
    setState(() {
      _isLoading = true;
    });

    final navigator = Navigator.of(context);

    try {
      final result = await sendRequest(
        context: context,
        mounted: mounted,
        uri: '/user/login/',
        type: 'POST',
        body: {'email': _email.text, 'password': _password.text},
      );

      if (result['error'] == 0) {
        // Store the user data in shared preferences.
        await addToken(result);

        navigator.pushReplacementNamed('/dashboard/');
      } else {
        if (!mounted) return;

        await showErrorDialog(
          context,
          result['msg'],
        );
      }
    } catch (e) {
      devtools.log(e.toString());

      await showErrorDialog(context, 'Something went wrong.');
    }

    setState(() {
      _isLoading = false;
    });

    return;
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
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(top: 30),
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
                    obscureText: true,
                    suggestions: false,
                    autocorrect: false,
                    label: 'Password',
                  ),
                  CheckboxListTile(
                    title: const Text('Touch ID Login'),
                    value: false,
                    onChanged: (val) {
                      _touchId = val;
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await initLogin();
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
      ),
    );
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw 'Could not launch $url';
  }
}
