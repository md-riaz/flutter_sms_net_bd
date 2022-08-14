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
        drawer: appDrawer(context, mounted),
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
  late Future pageFuture;

  @override
  void initState() {
    pageFuture = _getBalance();
    super.initState();
  }

  Future _getBalance() async {
    Map<String, dynamic> data = {
      'balance': '0.00',
      'validity': null,
    };

    try {
      final resp = await sendRequest(
          context: context, mounted: mounted, uri: '/user/balance');

      if (resp['error'] == 0) {
        data = {
          'balance': double.parse(resp['data']['balance']),
          'validity': DateFormat.yMMMd().format(
            DateTime.parse(resp['data']['validity']),
          ),
        };
      }
    } catch (e) {
      developer.log(e.toString());
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: pageFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return preloader;
          case ConnectionState.done:
          default:
            if (snapshot.hasError) {
              final error = snapshot.error;

              return Text('🥺 $error');
            } else if (snapshot.hasData) {
              Map<String, dynamic> data = snapshot.data;
              return Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/card-bg-1.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text(
                            'Current Balance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            data['balance'].toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 35.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Validity: ${data['validity'] != null ? data['validity'].toString() : ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // show alert that this feature is comming soon
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Coming Soon'),
                                content:
                                    const Text('This feature is comming soon'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(
                            side: BorderSide(
                              color: Colors.teal,
                              width: 3,
                            ),
                          ),
                          elevation: 0,
                          primary: Colors.white,
                          onPrimary: Colors.teal,
                          padding: const EdgeInsets.all(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: Text('No Data'));
        }
      },
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
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
                            fontSize: 16,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
