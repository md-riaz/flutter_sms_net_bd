// sms tab
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
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
  bool isLoading = false;

  final TextEditingController recipientController = TextEditingController();
  final TextEditingController smsContentController = TextEditingController();
  String formatedRecipient = '';
  String? _selectedSenderId;
  String? _scheduledDate;

  @override
  void initState() {
    pageFuture = getPageData();
    super.initState();
  }

  void _formatRecipient(text) {
    formatedRecipient =
        text.toString().trim().split(' ').join(',').split('\n').join(',');
  }

  void _selectSenderId(String val) {
    _selectedSenderId = val;
  }

  void _changeSMSContent(dynamic value) {
    smsContentController.text = value;
  }

  void _changeScheduledDate(String value) {
    log('_changeScheduledDate: $value');
    _scheduledDate = value;
  }

  Future<Map> getPageData() async {
    final pageData = await Future.wait([
      getApprovedSenderIds(context, mounted),
      getGroups(context, mounted, {}),
      getTemplates(context, mounted),
    ]);

    Map<String, dynamic> data = {
      'senderIdList': pageData[0],
      'groups': pageData[1],
      'templateList': pageData[2],
    };

    return data;
  }

  Future<bool> processSMSRequest(
      {senderId, recipients, smsContent, String? schedule}) async {
    try {
      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> response = await sendMessage(
        context: context,
        mounted: mounted,
        senderID: senderId,
        phone: recipients,
        message: smsContent,
        schedule: schedule ?? '',
      );

      if (!mounted) return false;

      showSnackBar(context, response['msg']);

      return response['error'] == 0;
    } catch (e) {
      log(e.toString());
      return false;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    recipientController.dispose();
    smsContentController.dispose();

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
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('Sender ID'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 50,
                                child: ChoiceChipSelector(
                                    choiceList: snapshot.data['senderIdList'],
                                    onChanged: (String val) {
                                      _selectSenderId(val);
                                    },
                                    selectedChoice: null,
                                    labelProperty: 'sender_id'),
                              ),
                            ),
                            FormText(
                              label: 'Individual Recipient Numbers',
                              controller: recipientController,
                              hintText:
                                  'Enter one or more recipient numbers separated by commas',
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return 'Recipient numbers are required';
                                } else if (!val.isPhoneNumber) {
                                  return 'Invalid phone number';
                                }

                                return null;
                              },
                              keyboardType: TextInputType.phone,
                              onChanged: _formatRecipient,
                              maxLines: 2,
                              bordered: false,
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
                              bordered: false,
                            ),
                            formSpacer,
                            DateTimeFormText(
                              notifyParent: _changeScheduledDate,
                            ),
                            formSpacer,
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(40),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final processDone = await processSMSRequest(
                                      senderId: _selectedSenderId,
                                      recipients: formatedRecipient,
                                      smsContent: smsContentController.text,
                                      schedule: _scheduledDate,
                                    );

                                    if (processDone) {
                                      _formKey.currentState!.reset();
                                      _scheduledDate = null;
                                    }
                                  }
                                },
                                child: isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Submit Request'),
                              ),
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
}

class ChoiceChipSelector extends StatefulWidget {
  final List<dynamic> choiceList;
  final Function(String)? onChanged;
  final String? selectedChoice;
  final String labelProperty;

  const ChoiceChipSelector({
    Key? key,
    required this.choiceList,
    required this.onChanged,
    required this.selectedChoice,
    required this.labelProperty,
  }) : super(key: key);

  @override
  State<ChoiceChipSelector> createState() => _ChoiceChipSelectorState();
}

class _ChoiceChipSelectorState extends State<ChoiceChipSelector> {
  int choiceIndex = 0;
  bool isSelected = false;
  late List choices = [
    {'id': 0, 'sender_id': 'Default'},
  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      choices.addAll(widget.choiceList);
    });
  }

  void handleChoiceChange(int index) {
    setState(() {
      choiceIndex = index;
      isSelected = true;
    });

    widget.onChanged!(choices[index][widget.labelProperty] == 'Default'
        ? ''
        : choices[index][widget.labelProperty]);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: choices.map((choice) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(choice[widget.labelProperty]),
              selected: choiceIndex == choices.indexOf(choice),
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.teal,
              onSelected: (selected) {
                handleChoiceChange(selected ? choices.indexOf(choice) : 0);
              },
              labelStyle: TextStyle(
                color: choiceIndex == choices.indexOf(choice)
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
