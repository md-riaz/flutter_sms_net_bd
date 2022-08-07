// sms tab
import 'dart:developer';

import 'package:flutter/material.dart';
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
    super.initState();
  }

  @override
  void dispose() {
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

                  buildSenderIdDropdown(snapshot.data['senderIdList']);
                  buildGroupRecipientsDropdown(snapshot.data['groups']);
                  buildTemplateDropdown(snapshot.data['templateList']);

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sender ID'),
                              DropdownButtonFormField(
                                value: _selectedSenderId,
                                // ignore: unnecessary_question_mark
                                onChanged: (dynamic? newValue) {
                                  setState(() => _selectedSenderId = newValue!);
                                },
                                items: senderIdDropdownItems,
                              ),
                            ],
                          ),
                        ),
                        formSpacer,
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Group Recipients'),
                              DropdownButtonFormField(
                                value: _selectedGroup,
                                // ignore: unnecessary_question_mark
                                onChanged: (dynamic? newValue) {
                                  setState(() => _selectedGroup = newValue);
                                },
                                items: groupDropdownItems,
                              ),
                            ],
                          ),
                        ),
                        formSpacer,
                        const FormText(
                          label: 'Individual Recipient Numbers',
                          hintText:
                              'Enter one or more recipient numbers separated by commas',
                          maxLines: 5,
                          bordered: true,
                        ),
                        formSpacer,
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SMS Templates'),
                              DropdownButtonFormField(
                                value: _selectedTemplate,
                                // ignore: unnecessary_question_mark
                                onChanged: (dynamic? newValue) {
                                  setState(() => _selectedTemplate = newValue);
                                },
                                items: templateDropdownItems,
                              ),
                            ],
                          ),
                        ),
                        formSpacer,
                        const FormText(
                          label: 'Enter SMS Content',
                          maxLines: 5,
                          bordered: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(25),
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
                            selectedValue: '0',
                          ),
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
