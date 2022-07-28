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
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade100,
      child: SafeArea(
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
              margin: const EdgeInsets.only(top: 16),
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

      if (resp != null) {
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

  late final TextEditingController _to;
  late final TextEditingController _body;

  @override
  void initState() {
    _to = TextEditingController();
    _body = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _to.dispose();
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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _sendSMS(
                      context: context,
                      to: _to.text,
                      body: _body.text,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _sendSMS({
    required BuildContext context,
    required String to,
    required String body,
  }) async {
    Map<String, dynamic> response =
        await sendMessage(context, mounted, to, body);

    if (!mounted) return;

    showSnackBar(context, response['msg']);
  }
}
