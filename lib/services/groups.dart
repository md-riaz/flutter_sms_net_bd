import 'package:sms_net_bd/utils/api_client.dart';

Future getGroups(context, mounted) async {
  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/phonebook/group/',
  );

  if (resp['error'] == 0) {
    return resp['data']['table_content']['group'];
  }

  return [];
}
