import 'package:sms_net_bd/utils/api_client.dart';

Future getCompleteRequests(context, mounted, queryParams) async {
  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/report/request/${queryParams['request_id']}',
    queryParameters: queryParams,
  );

  if (resp['error'] == 0) {
    if (queryParams['request_id'] != null) {
      return resp['data']['table_content']['request_details'];
    }

    return resp['data']['table_content']['request'];
  }

  return [];
}
