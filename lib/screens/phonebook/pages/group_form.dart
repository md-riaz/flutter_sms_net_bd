import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sms_net_bd/services/groups.dart';
import 'package:sms_net_bd/utils/api_client.dart';
import 'package:sms_net_bd/widgets/form_text.dart';

class GroupForm extends StatefulWidget {
  final String title;
  final Map? formData;

  const GroupForm({Key? key, required this.title, this.formData})
      : super(key: key);

  @override
  State<GroupForm> createState() => _GroupFormState();
}

class _GroupFormState extends State<GroupForm> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.formData != null) {
      nameController.text = widget.formData!['group_name'];
    }
  }

  Future<void> handleSubmit() async {
    try {
      setState(() {
        isLoading = true;
      });

      final data = {'name': nameController.text};

      if (widget.formData != null) {
        data['id'] = widget.formData!['id'].toString();
      }

      final resp = await saveGroup(context, mounted, data);

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
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FormText(
                label: 'Group Name',
                maxLength: 30,
                controller: nameController,
                keyboardType: TextInputType.text,
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please enter group name';
                  }
                  return null;
                },
              ),
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
}
