import 'package:sms_net_bd/utils/api_client.dart';

Future getContacts(context, mounted, queryParams) async {
  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/phonebook/contact/',
    queryParameters: queryParams,
  );

  if (resp['error'] == 0) {
    return resp['data']['table_content']['contact'];
  }

  return [];
}

Future saveContact(context, mounted, data) async {
  final uri = data['id'] != null
      ? '/phonebook/contact/edit/${data['id']}'
      : '/phonebook/contact/add';

  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: uri,
    type: 'POST',
    body: data,
  );

  return resp;
}
