import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms_net_bd/utils/api_client.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/widgets/app_bar.dart';
import 'package:sms_net_bd/widgets/app_drawer.dart';
import 'package:sms_net_bd/widgets/form_text.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();

  double balance = 0.00;
  String validity = '';

  late final _to;
  late final _body;

  @override
  void initState() {
    _to = TextEditingController();
    _body = TextEditingController();
    super.initState();

    getBalance();
  }

  getBalance() async {
    final resp = await sendRequest(uri: '/user/balance');

    setState(() {
      balance = double.parse(resp['data']['balance']);
      validity =
          DateFormat.yMMMd().format(DateTime.parse(resp['data']['validity']));
    });
  }

  @override
  void dispose() {
    _to.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        title: 'Dashboard',
        mounted: mounted,
      ),
      drawer: appDrawer(context),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.teal[400]!,
                  Colors.teal[600]!,
                  Colors.teal[500]!,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Current Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  balance.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 50.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Validity: $validity',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          formSpacer,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormText(
                        label: 'Mobile Number',
                        controller: _to,
                        keyboardType: TextInputType.number,
                        bordered: true,
                      ),
                      FormText(
                        label: 'Message',
                        controller: _body,
                        bordered: true,
                        maxLength: 1000,
                        maxLines: 5,
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          primary: Colors.teal[400],
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 32,
                          ),
                        ),
                        child: const Text('Send'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            print(_to.text);
                            print(_body.text);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
