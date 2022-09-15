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

Future saveGroup(context, mounted, body) async {
  final uri = body['id'] != null
      ? '/phonebook/group/edit/${body['id']}'
      : '/phonebook/group/add';

  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: uri,
    type: 'POST',
    body: body,
  );

  return resp;
}

// delete group
Future deleteGroup(context, mounted, id) async {
  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/phonebook/group/delete/$id',
  );

  return resp['error'] == 0;
}
