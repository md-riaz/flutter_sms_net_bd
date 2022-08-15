import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms_net_bd/utils/api_client.dart';

Future getDashboardData(BuildContext context, mounted) async {
  final pageData = await Future.wait([
    getBalance(context, mounted),
    getDashboard(context, mounted),
  ]);

  // return a Map of data
  return {
    'balance': pageData[0],
    'dashboard': pageData[1],
  };
}

Future getBalance(BuildContext context, mounted) async {
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
    log(e.toString());
  }

  return data;
}

Future getDashboard(BuildContext context, mounted) async {
  Map<String, dynamic> data = {
    'chart': {},
    'statistics': {},
  };

  try {
    final resp = await sendRequest(
        context: context, mounted: mounted, uri: '/dashboard/');

    if (resp['error'] == 0) {
      data = resp['data'];
    }
  } catch (e) {
    log(e.toString());
  }

  return data;
}
