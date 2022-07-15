import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_net_bd/utils/constants.dart';

Future sendRequest({
  required String uri,
  String type = 'GET',
  dynamic body,
}) async {
  final client = http.Client();

  Map<String, String> headers = {};

  String? token = await getToken();

  if (token != null) {
    headers['x-auth-token'] = token;
  }

  final url = '$baseAPI$uri';

  http.Response? response;

  if (type == 'POST') {
    response = await client.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
  } else {
    response = await client.get(
      Uri.parse(url),
      headers: headers,
    );
  }

  final Map<String, dynamic> result = jsonDecode(response.body);

  return result;
}

// get token from shared preferences
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  return token;
}

// check authentication
Future checkAuthentication() async {
  final token = await getToken();
  if (token == null) {
    return false;
  }
  final response = await sendRequest(
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
