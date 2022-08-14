import 'package:sms_net_bd/utils/api_client.dart';

Future getGroups(context, mounted, Map<String, dynamic>? queryParams) async {
  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/phonebook/group/',
    queryParameters: queryParams,
  );

  if (resp['error'] == 0) {
    return resp['data']['table_content']['group'];
  }

  return [];
}
