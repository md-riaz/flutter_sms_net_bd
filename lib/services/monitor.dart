import 'package:flutter/cupertino.dart';
import 'package:sms_net_bd/utils/api_client.dart';

Future getMonitorData(BuildContext context, mounted) async {
  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/monitor/',
    type: 'GET',
  );

  if (resp['error'] == 0) {
    return resp['data'];
  }

  return [];
}
