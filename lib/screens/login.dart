import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_net_bd/utils/api_client.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/widgets/form_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  late final TextEditingController _email;
  late final TextEditingController _password;

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
      final Map<String, dynamic> result = await sendRequest(
        uri: '/user/login/',
        type: 'POST',
        body: {
          'email': _email.text,
          'password': _password.text,
          'client_ip': '',
          'api_key': appKey,
          'origin': '',
        },
      );

      if (result['error'] == 0) {
        // Obtain shared preferences.
        final prefs = await SharedPreferences.getInstance();
        // Store the user data in shared preferences.
        prefs.setString('token', result['token']);

        prefs.setInt('userId', result['data']['user']['id']);
        prefs.setString('userName', result['data']['user']['name']);
        prefs.setString('userGroup', result['data']['user']['group']);

        navigator.pushReplacementNamed('/dashboard/');
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
      print(e);
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
                  formSpacer,
                  FormText(
                    controller: _password,
                    obscureText: true,
                    suggestions: false,
                    autocorrect: false,
                    label: 'Password',
                  ),
                  formSpacer,
                  InkWell(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await initLogin();
                        }
                      },
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
}
