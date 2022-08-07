import 'package:sms_net_bd/utils/api_client.dart';

Future getApprovedSenderIds(context, mounted) async {
  final resp = await sendRequest(
      context: context,
      mounted: mounted,
      uri: '/config/senderid/',
      queryParameters: {'s': 'Approved'});

  if (resp['error'] == 0) {
    return resp['data']['items'];
  }

  return [];
}
