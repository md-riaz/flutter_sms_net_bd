import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/utils/routes.dart';

Future sendRequest({
  required BuildContext context,
  required bool mounted,
  required String uri,
  String type = 'GET',
  Map<String, dynamic>? body,
  Map<String, dynamic>? queryParameters,
}) async {
  final client = http.Client();

  Map<String, String> headers = {
    'content-type': 'application/json',
  };

  String? token = await getToken();

  if (token != null) {
    headers['x-auth-token'] = token;
  }

  final url = Uri.https(
    Uri.parse(baseAPI).toString(),
    uri,
    queryParameters,
  );

  http.Response? response;

  try {
    if (!mounted) return;

    if (type == 'POST') {
      response = await client.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
    } else {
      response = await client.get(
        url,
        headers: headers,
      );
    }

    final Map<String, dynamic> result = jsonDecode(response.body);

    if (result['error'] == 405) {
      await removeToken();

      if (!mounted) return;

      Navigator.of(context)
          .pushNamedAndRemoveUntil(loginRoute, (route) => false);
    }

    return result;
  } catch (e) {
    log(e.toString());
  } finally {
    client.close();
  }

  return {};
}

// get token from shared preferences
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  return token;
}

// check authentication
Future checkAuthentication(BuildContext context, bool mounted) async {
  final token = await getToken();

  if (token == null) {
    return false;
  }
  final response = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/user/balance/',
    type: 'GET',
  );
  if (response['error'] == 0) {
    return true;
  }

  await removeToken();
  return false;
}

Future<void> addToken(Map<String, dynamic> response) async {
  final prefs = await SharedPreferences.getInstance();

  prefs.setString('token', response['token']);

  prefs.setInt('userId', response['data']['user']['id']);
  prefs.setString('userName', response['data']['user']['name']);
  prefs.setString('userGroup', response['data']['user']['group']);
}

Future<void> removeToken() async {
  final prefs = await SharedPreferences.getInstance();

  prefs.remove('token');
  prefs.remove('userId');
  prefs.remove('userName');
  prefs.remove('userGroup');
}

void logOut(BuildContext context, mounted) async {
  await removeToken();

  if (!mounted) return;

  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
}

Future<Map<String, dynamic>> sendMessage({
  required BuildContext context,
  required bool mounted,
  String? senderID,
  required String phone,
  required String message,
  String? schedule,
}) async {
  Map<String, dynamic> body = {
    'to': phone,
    'msg': message,
    'senderid': senderID,
    'schedule': schedule,
  };

  final response = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/sendsms/',
    type: 'POST',
    body: body,
  );

  return response;
}

void showSnackBar(BuildContext context, String text, {Duration? duration}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: duration ?? const Duration(seconds: 2),
    ),
  );
}
