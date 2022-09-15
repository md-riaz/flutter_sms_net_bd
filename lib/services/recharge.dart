import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_net_bd/utils/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

Future rechargeBalance(BuildContext context, mounted, amount) async {
  final prefs = await SharedPreferences.getInstance();

  final userid = prefs.getInt('userId');

  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/recharge/package/',
    type: 'POST',
    body: {'recharge_amount': amount, 'user_id': userid},
  );

  if (resp['error'] == 0 && resp['data']['checkout_url'] != null) {
    launchUrl(resp['data']['checkout_url']);
  } else {
    log(resp['message']);
  }

  return true;
}
