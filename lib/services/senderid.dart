import 'package:flutter/material.dart';
import 'package:sms_net_bd/utils/api_client.dart';

Future getApprovedSenderIds(BuildContext context, mounted) async {
  final resp = await sendRequest(
      context: context,
      mounted: mounted,
      uri: '/config/senderid/',
      queryParameters: {'s': 'Approved'});

  if (resp['error'] == 0) {
    return resp['data']['items'];
  }

  return [];
}

Future getSenderIds(BuildContext context, mounted) async {
  final resp = await sendRequest(
      context: context, mounted: mounted, uri: '/config/senderid/');

  if (resp['error'] == 0) {
    return resp['data']['items'];
  }

  return [];
}

Future addSenderId(BuildContext context, mounted, String senderId) async {
  final resp = await sendRequest(
      context: context,
      mounted: mounted,
      uri: '/config/senderid/add',
      type: 'POST',
      body: {'sender_id': senderId});

  return resp;
}
