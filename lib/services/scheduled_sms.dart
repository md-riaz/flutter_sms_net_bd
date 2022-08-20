import 'package:sms_net_bd/utils/api_client.dart';

Future<List> getScheduledSMSList(context, mounted) async {
  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/messaging/schedule/',
  );

  if (resp['error'] == 0) {
    return resp['data']['table_content']['scheduled']['items'];
  }

  return [];
}

Future<bool> updateScheduledSMS(context, mounted, id, data) async {
  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/messaging/schedule/edit/$id/',
    type: 'POST',
    body: data,
  );

  if (resp['error'] == 0) {
    return true;
  }
  return false;
}

Future<bool> deleteScheduledSMS(context, mounted, id) async {
  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/messaging/schedule/delete/$id',
  );

  return resp['error'] == 0;
}
