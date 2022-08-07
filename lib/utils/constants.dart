import 'package:flutter/material.dart';

const baseAPI =
    'sms-api-proxy.cyclic.app'; // https://smsapi.glitch.me // https://sms-api-proxy.cyclic.app/ // https://smsapi-proxy.herokuapp.com/

const preloader = Center(
  child: CircularProgressIndicator(
    color: Colors.teal,
  ),
);

const formSpacer = SizedBox(
  width: 16,
  height: 16,
);
