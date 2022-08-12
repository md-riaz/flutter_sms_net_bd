// sms tab
import 'dart:async';
import 'dart:developer';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:sms_net_bd/screens/messaging/widgets/senderid_dropdown.dart';
import 'package:sms_net_bd/screens/messaging/widgets/template_dropdown.dart';
import 'package:sms_net_bd/services/groups.dart';
import 'package:sms_net_bd/services/senderid.dart';
import 'package:sms_net_bd/services/templates.dart';
import 'package:sms_net_bd/utils/api_client.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/widgets/datetime_formtext.dart';
import 'package:sms_net_bd/widgets/form_text.dart';

class SMSTab extends StatefulWidget {
  const SMSTab({Key? key}) : super(key: key);

  @override
  State<SMSTab> createState() => _SMSTabState();
}

class _SMSTabState extends State<SMSTab> {
  final _formKey = GlobalKey<FormState>();
  Future? pageFuture;

  final TextEditingController recipientController = TextEditingController();
  late TextEditingController smsContentController = TextEditingController();
  String formatedRecipient = '';
  String? _selectedSenderId;

  @override
  void initState() {
    pageFuture = getPageData();
    super.initState();
  }

  void _formatRecipient(text) {
    formatedRecipient =
        text.toString().trim().split(' ').join(',').split('\n').join(',');
    log(formatedRecipient);
  }

  void _selectSenderId(String val) {
    _selectedSenderId = val;
  }

  void _changeSMSContent(dynamic value) {
    smsContentController.text = value;
  }

  // keep a reference to CancelableOperation
  CancelableOperation? _myCancelableFuture;

  Future<Map> reqPageData() async {
    final pageData = await Future.wait([
      getApprovedSenderIds(context, mounted),
      getGroups(context, mounted),
      getTemplates(context, mounted),
    ]);

    Map<String, dynamic> data = {
      'senderIdList': pageData[0],
      'groups': pageData[1],
      'templateList': pageData[2],
    };

    return data;
  }

  Future<Map> getPageData() async {
    _myCancelableFuture = CancelableOperation.fromFuture(
      reqPageData(),
      onCancel: () => 'Future has been canceld',
    );

    final data = await _myCancelableFuture?.value;

    return data;
  }

  Future<bool> processSMSRequest({senderId, recipients, smsContent}) async {
    try {
      Map<String, dynamic> response = await sendMessage(
        context: context,
        mounted: mounted,
        senderID: senderId,
        phone: recipients,
        message: smsContent,
      );

      if (!mounted) return false;

      showSnackBar(context, response['msg']);

      return response['error'] == 0;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    recipientController.dispose();
    smsContentController.dispose();
    _myCancelableFuture?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<void>(
            future: pageFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return preloader;
                case ConnectionState.done:
                default:
                  if (snapshot.hasError) {
                    final error = snapshot.error;

                    return Text('🥺 $error');
                  } else if (snapshot.hasData) {
                    return Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SenderIdDropdown(
                              senderIdDropdown: snapshot.data['senderIdList'],
                              onChanged: _selectSenderId,
                            ),
                            formSpacer,
                            FormText(
                              label: 'Individual Recipient Numbers',
                              controller: recipientController,
                              hintText:
                                  'Enter one or more recipient numbers separated by commas',
                              keyboardType: TextInputType.phone,
                              onChanged: _formatRecipient,
                              maxLines: 2,
                              bordered: true,
                            ),
                            formSpacer,
                            TemplateDropdown(
                              templateItems: snapshot.data['templateList'],
                              notifyParent: _changeSMSContent,
                            ),
                            formSpacer,
                            FormText(
                              label: 'Enter SMS Content',
                              controller: smsContentController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              maxLines: 3,
                              bordered: true,
                            ),
                            const DateTimeFormText(),
                            formSpacer,
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final processDone = await processSMSRequest(
                                    senderId: _selectedSenderId,
                                    recipients: formatedRecipient,
                                    smsContent: smsContentController.text,
                                  );

                                  if (processDone) {
                                    _formKey.currentState!.reset();
                                    setState(() {});
                                  }
                                }
                              },
                              child: const Text('Submit Request'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return const Center(child: Text('No Data'));
              }
            }),
      ),
    );
  }

  // buildGroupRecipientsDropdown(data) {
  //   data?.forEach((item) {
  //     groupDropdownItems.add(
  //       DropdownMenuItem(
  //         value: item['id'],
  //         child: Text(item['group_name']),
  //       ),
  //     );
  //   });
  // }
}
