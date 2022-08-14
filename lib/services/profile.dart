import 'package:sms_net_bd/utils/api_client.dart';

Future getProfile(context, mounted) async {
  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/user/',
  );

  if (resp['error'] == 0) {
    return resp['data']['item'];
  }

  return [];
}
