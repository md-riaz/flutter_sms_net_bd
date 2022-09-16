import 'dart:developer' as developer show log;

import 'package:flutter/material.dart';
import 'package:sms_net_bd/services/dashboard.dart';
import 'package:sms_net_bd/services/recharge.dart';
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
  Future? pageFuture;

  @override
  void initState() {
    super.initState();
    pageFuture = getPageData();
  }

  Future<Map> getPageData() async {
    return await getDashboardData(context, mounted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        title: 'Dashboard',
        mounted: mounted,
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: pageFuture,
        builder: (BuildContext context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: preloader,
              );
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                final error = snapshot.error;

                return Text('🥺 $error');
              } else if (snapshot.hasData) {
                final Map data = snapshot.data as Map;

                return SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TopStats(
                          stats: data['dashboard']['statistics'],
                        ),
                        formSpacer,
                        BalanceCard(data: data['balance']),
                        formSpacer,
                        const QuickMsg(),
                      ],
                    ),
                  ),
                );
              }

              return const Center(child: Text('No Data'));
          }
        },
      ),
    );
  }
}

class TopStats extends StatelessWidget {
  final Map stats;

  const TopStats({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        Card(
          color: isDarkMode ? null : Colors.teal.shade100,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.43,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stats['today']['count'].toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cost: BDT. ${double.parse(stats['today']['cost'].toString()).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          color: isDarkMode ? null : Colors.purple.shade100,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.43,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yesterday',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stats['yesterday']['count'].toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cost: BDT. ${double.parse(stats['yesterday']['cost'].toString()).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          color: isDarkMode ? null : Colors.blue.shade100,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.43,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This Week',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stats['week']['count'].toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cost: BDT. ${double.parse(stats['week']['cost'].toString()).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          color: isDarkMode ? null : Colors.green.shade100,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.43,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This Month',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stats['month']['count'].toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cost: BDT. ${double.parse(stats['month']['cost'].toString()).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BalanceCard extends StatefulWidget {
  final Map data;

  const BalanceCard({Key? key, required this.data}) : super(key: key);

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  TextEditingController rechargeAmount = TextEditingController();

  @override
  void dispose() {
    rechargeAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/card-bg-1.png'),
            colorFilter: Theme.of(context).brightness == Brightness.dark
                ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                : null,
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
                  widget.data['balance'].toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 35.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Validity: ${widget.data['validity'] != null ? widget.data['validity'].toString() : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Recharge Amount'),
                      content: FormText(
                        label: 'Amount',
                        keyboardType: TextInputType.number,
                        controller: rechargeAmount,
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            showSnackBar(context, 'Processing...');
                            await rechargeBalance(
                              context,
                              mounted,
                              rechargeAmount.text,
                            );

                            if (!mounted) return;
                            Navigator.of(context).pop();
                          },
                          child: const Text('CONFIRM'),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.teal,
                shape: const CircleBorder(
                  side: BorderSide(
                    color: Colors.teal,
                    width: 3,
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
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
