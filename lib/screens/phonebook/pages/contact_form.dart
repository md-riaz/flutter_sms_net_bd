import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sms_net_bd/services/contacts.dart';
import 'package:sms_net_bd/services/groups.dart';
import 'package:sms_net_bd/utils/api_client.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/widgets/form_text.dart';
import 'package:sms_net_bd/widgets/multiselect.dart';

class ContactForm extends StatefulWidget {
  final String title;
  final Map? formData;

  const ContactForm({Key? key, required this.title, this.formData})
      : super(key: key);

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();

  Future? pageFuture;
  bool isLoading = false;
  bool _status = true;
  List? groupItems;
  List? selectedGroups;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController groupsController = TextEditingController();

  @override
  void initState() {
    pageFuture = getPageData();
    super.initState();

    if (widget.formData != null) {
      nameController.text = widget.formData!['name'];
      phoneController.text = widget.formData!['number'];
      emailController.text = widget.formData!['email'];
      groupItems = widget.formData!['groups'];
      _status = widget.formData!['status'] == '1';
    }
  }

  Future<void> handleSubmit() async {
    try {
      setState(() {
        isLoading = true;
      });

      final data = {
        'name': nameController.text,
        'number': phoneController.text,
        'email': emailController.text,
        'status': _status ? '1' : '0',
      };

      if (selectedGroups!.isNotEmpty) {
        for (var g in selectedGroups!) {
          data["group[$g]"] = g.toString();
        }
      }

      if (widget.formData != null) {
        data['id'] = widget.formData!['id'].toString();
      }

      final resp = await saveContact(context, mounted, data);

      if (resp['error'] == 0) {
        if (!mounted) return;
        Navigator.pop(context, true);
      }

      if (!mounted) return;

      showSnackBar(context, resp['msg']);
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: pageFuture,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          FormText(
                            label: 'Name',
                            maxLength: 20,
                            controller: nameController,
                            keyboardType: TextInputType.text,
                          ),
                          FormText(
                            label: 'Phone',
                            maxLength: 15,
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          FormText(
                            label: 'Email',
                            maxLength: 50,
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          FormText(
                            controller: groupsController,
                            label: 'Group Recipients',
                            readOnly: true,
                            onTap: () => handleGroupTap(snapshot.data),
                          ),
                          SwitchListTile(
                            title: const Text('Status'),
                            value: _status,
                            onChanged: (bool value) {
                              setState(() {
                                _status = value;
                              });
                            },
                          ),
                          formSpacer,
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: ElevatedButton(
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 16.0,
                                            width: 16.0,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Save'),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        handleSubmit();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }

              return const Center(child: Text('No Data'));
          }
        },
      ),
    );
  }

  Future<List> getPageData() async {
    final List pageData = await getGroups(context, mounted, {});

    // if it is an edit form, then set the selected groups
    if (widget.formData != null &&
        pageData.isNotEmpty &&
        widget.formData!['groups'].isNotEmpty) {
      final selectedGroupText = groupItems!.map((groupId) {
        final item = pageData.firstWhere((element) => element['id'] == groupId,
            orElse: () => null);
        return item?['group_name'];
      }).toList();

      selectedGroups = widget.formData!['groups'];
      selectedGroupText.removeWhere((v) => v == null);
      groupsController.text = selectedGroupText.join(', ');
    }

    return pageData;
  }

  void handleGroupTap(groups) async {
    final selected = await showMultiSelect(groups, groupItems);

    if (selected != null) {
      setState(() {
        groupItems = selected;

        final selectedGroupText = groupItems!.map((groupId) {
          final item = groups.firstWhere((element) => element['id'] == groupId);
          return item['group_name'];
        }).toList();

        selectedGroups = selected;

        groupsController.text = selectedGroupText.join(', ');
      });
    }
  }

  Future<List?> showMultiSelect(List items, selectedValues) async {
    final selectItems = <MultiSelectDialogItem>[];

    if (items.isNotEmpty) {
      for (var item in items) {
        selectItems.add(MultiSelectDialogItem(item['id'], item['group_name']));
      }
    }

    final List? selectedItems = await showDialog<List<dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: selectItems,
          initialSelectedValues: selectedValues,
        );
      },
    );

    return selectedItems;
  }
}
