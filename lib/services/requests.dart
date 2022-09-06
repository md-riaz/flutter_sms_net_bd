import 'package:sms_net_bd/utils/api_client.dart';

Future getCompleteRequests(context, mounted, queryParams) async {
  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/report/request/',
    queryParameters: queryParams,
  );

  if (resp['error'] == 0) {
    return resp['data']['table_content']['request'];
  }

  return [];
}
