import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sms_net_bd/utils/constants.dart';

Future sendRequest({required String uri, dynamic body}) async {
  final client = http.Client();

  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  final url = '$baseAPI$uri';

  http.Response response = await client.post(
    Uri.parse(url),
    // headers: headers,
    body: body,
  );

  final Map<String, dynamic> result = jsonDecode(response.body);

  return result;
}
