import 'package:flutter/material.dart';
import 'package:sms_net_bd/screens/dashboard.dart';
import 'package:sms_net_bd/utils/constants.dart';

import '../utils/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
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
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!val.isValidEmail) {
                        return 'Please enter a valid email';
                      }

                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await initLogin(context);
                        }
                      },
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/register/', (route) => false);
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

  Future initLogin(BuildContext context) async {
    try {
      final Map result = await sendRequest(
        uri: '/user/login/',
        body: {
          'email': _email.text,
          'password': _password.text,
          'client_ip': '',
          'api_key': appKey,
          'origin': '',
        },
      );

      if (!mounted) return;

      if (result['error'] == 0) {
        return Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
          (route) => false,
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid email or password'),
            actions: [
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Something went wrong'),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    return null;
  }
}
