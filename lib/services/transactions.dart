import 'package:sms_net_bd/utils/api_client.dart';

Future getTransactions(context, mounted, queryParams) async {
  final resp = await sendRequest(
    context: context,
    mounted: mounted,
    uri: '/user/transactions/',
    queryParameters: queryParams,
  );

  if (resp['error'] == 0) {
    return resp['data']['table_content']['transaction'];
  }

  return [];
}
