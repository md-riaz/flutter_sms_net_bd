// sms tab
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sms_net_bd/screens/messaging/widgets/senderid_dropdown.dart';
import 'package:sms_net_bd/screens/messaging/widgets/template_dropdown.dart';
import 'package:sms_net_bd/services/groups.dart';
import 'package:sms_net_bd/services/senderid.dart';
import 'package:sms_net_bd/services/templates.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/widgets/form_text.dart';
import 'package:sms_net_bd/widgets/radio_group.dart';

class SMSTab extends StatefulWidget {
  const SMSTab({Key? key}) : super(key: key);

  @override
  State<SMSTab> createState() => _SMSTabState();
}

class _SMSTabState extends State<SMSTab> {
  final GlobalKey _formKey = GlobalKey<FormState>();

  late TextEditingController smsContent;

  var senderIds;
  var groupRecipients;
  var templates;

  String? _selectedSenderId;
  String? _selectedGroup;
  String? _selectedTemplate;

  List<DropdownMenuItem> senderIdDropdownItems = [
    const DropdownMenuItem(
      value: null,
      child: Text('Default'),
    ),
  ];

  List<DropdownMenuItem> groupDropdownItems = [
    const DropdownMenuItem(
      value: null,
      child: Text('Select One'),
    ),
  ];

  List<DropdownMenuItem> templateDropdownItems = [
    const DropdownMenuItem(
      value: null,
      child: Text('Select One'),
    ),
  ];

  // Default Radio Button Selected Item When App Starts.
  String scheduledSms = '0';

  @override
  void initState() {
    smsContent = TextEditingController();
    super.initState();
  }

  void _changeScheduledSms(String value) {
    scheduledSms = value;
  }

  void _changeSMSContent(dynamic value) {
    smsContent.text = value;
  }

  @override
  void dispose() {
    smsContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: FutureBuilder<void>(
            future: getPageData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return preloader;
                case ConnectionState.done:
                  log(snapshot.data.toString());

                  buildGroupRecipientsDropdown(snapshot.data['groups']);
                  buildTemplateDropdown(snapshot.data['templateList']);

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SenderIdDropdown(
                          senderIdDropdown: snapshot.data['senderIdList'],
                        ),
                        formSpacer,
                        TemplateDropdown(
                          templateItems: snapshot.data['templateList'],
                          notifyParent: _changeSMSContent,
                        ),
                        formSpacer,
                        FormText(
                          label: 'Enter SMS Content',
                          controller: smsContent,
                          maxLines: 5,
                          bordered: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: RadioGroup(
                            radioButtonValues: const [
                              {
                                'value': '0',
                                'label': 'Send Now',
                              },
                              {
                                'value': '1',
                                'label': 'Schedule',
                              }
                            ],
                            selectedValue: scheduledSms,
                            notifyParent: _changeScheduledSms,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            log(scheduledSms);
                          },
                          child: const Text('Press Button'),
                        ),
                      ],
                    ),
                  );

                default:
                  return const Text('Error');
              }
            },
          ),
        ),
      ),
    );
  }

  Future getPageData() async {
    final senderIdList = await getApprovedSenderIds(context, mounted);
    final groups = await getGroups(context, mounted);
    final templateList = await getTemplates(context, mounted);

    Map<String, dynamic> data = {
      'senderIdList': senderIdList,
      'groups': groups,
      'templateList': templateList,
    };

    return data;
  }

  buildSenderIdDropdown(data) {
    data.forEach((item) {
      senderIdDropdownItems.add(
        DropdownMenuItem(
          value: item['sender_id'],
          child: Text(item['sender_id']),
        ),
      );
    });
  }

  buildGroupRecipientsDropdown(data) {
    data?.forEach((item) {
      groupDropdownItems.add(
        DropdownMenuItem(
          value: item['id'],
          child: Text(item['group_name']),
        ),
      );
    });
  }

  buildTemplateDropdown(data) {
    data?.forEach((item) {
      templateDropdownItems.add(
        DropdownMenuItem(
          value: item['text'],
          child: Text(item['name']),
        ),
      );
    });
  }
}
