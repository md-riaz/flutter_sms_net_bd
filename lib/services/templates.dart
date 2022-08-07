import 'package:sms_net_bd/utils/api_client.dart';

Future getTemplates(context, mounted) async {
  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/messaging/template/',
  );

  if (resp['error'] == 0) {
    return resp['data']['table_content']['template'];
  }

  return [];
}
