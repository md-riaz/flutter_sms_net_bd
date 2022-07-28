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
  dynamic body,
}) async {
  final client = http.Client();

  Map<String, String> headers = {
    'content-type': 'application/json',
  };

  String? token = await getToken();

  if (token != null) {
    headers['x-auth-token'] = token;
  }

  final url = '$baseAPI$uri';

  http.Response? response;

  try {
    if (type == 'POST') {
      response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
    } else {
      response = await client.get(
        Uri.parse(url),
        headers: headers,
      );
    }

    final Map<String, dynamic> result = jsonDecode(response.body);
    log(result.toString());
    if (result['error'] == 405) {
      await removeToken();

      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(loginRoute, (route) => false);
    }

    if (result['error'] == 0) {
      return result;
    }

    return [];
  } catch (e) {
    log(e.toString());
  } finally {
    client.close();
  }
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

Future<Map<String, dynamic>> sendMessage(
  BuildContext context,
  bool mounted,
  String phone,
  String message,
) async {
  Map<String, dynamic> response = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/sendsms/',
    type: 'POST',
    body: {
      'to': phone,
      'msg': message,
    },
  );

  return response;
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}
