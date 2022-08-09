import 'dart:developer' as developer show log;

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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: appBar(
          context,
          title: 'Dashboard',
          mounted: mounted,
        ),
        drawer: appDrawer(context),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: const [
                BalanceCard(),
                formSpacer,
                QuickMsg(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BalanceCard extends StatefulWidget {
  const BalanceCard({Key? key}) : super(key: key);

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  double balance = 0.00;
  String validity = '';

  _getBalance() async {
    try {
      final resp = await sendRequest(
          context: context, mounted: mounted, uri: '/user/balance');

      if (resp['error'] == 0) {
        setState(() {
          balance = double.parse(resp['data']['balance']);
          validity = DateFormat.yMMMd().format(
            DateTime.parse(resp['data']['validity']),
          );
        });
      }
    } catch (e) {
      developer.log(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _getBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        borderRadius: BorderRadius.circular(5),
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
    );
  }
}

class QuickMsg extends StatefulWidget {
  const QuickMsg({Key? key}) : super(key: key);

  @override
  State<QuickMsg> createState() => _QuickMsgState();
}

class _QuickMsgState extends State<QuickMsg> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _phone;
  late final TextEditingController _body;

  bool _isLoading = false;

  @override
  void initState() {
    _phone = TextEditingController();
    _body = TextEditingController();
    super.initState();
  }

  Future<bool> _sendSMS({
    required BuildContext context,
    required String phone,
    required String body,
  }) async {
    try {
      setState(() => _isLoading = true);
      Map<String, dynamic> response = await sendMessage(
          context: context, mounted: mounted, phone: phone, message: body);

      if (!mounted) return false;

      showSnackBar(context, response['msg']);
      return response['error'] == 0;
    } catch (e) {
      developer.log(e.toString());
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FormText(
                label: 'Mobile Number',
                controller: _phone,
                keyboardType: TextInputType.number,
                bordered: true,
                validator: (val) {
                  if (!val!.isPhoneNumber) {
                    return 'Invalid Phone Number';
                  }

                  return null;
                },
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
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.teal,
                        ),
                      )
                    : const Text('Send',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final sent = await _sendSMS(
                      context: context,
                      phone: _phone.text,
                      body: _body.text,
                    );

                    if (sent) {
                      _formKey.currentState?.reset();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
