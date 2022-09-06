import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sms_net_bd/utils/api_client.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/widgets/form_text.dart';

class TemplateForm extends StatefulWidget {
  final String title;
  final int? tempId;
  final String? tempName;
  final String? tempBody;

  const TemplateForm(
      {Key? key,
      this.tempId,
      this.tempName,
      this.tempBody,
      required this.title})
      : super(key: key);

  @override
  State<TemplateForm> createState() => _TemplateFormState();
}

class _TemplateFormState extends State<TemplateForm> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.tempId != null) {
      nameController.text = widget.tempName!;
      bodyController.text = widget.tempBody!;
    }
  }

  Future<void> handleSubmit() async {
    try {
      setState(() {
        isLoading = true;
      });

      final Map<String, dynamic> data = {
        'name': nameController.text,
        'text': bodyController.text,
      };

      final url = widget.tempId != null
          ? '/messaging/template/edit/${widget.tempId}'
          : '/messaging/template/add';

      final response = await sendRequest(
        context: context,
        mounted: mounted,
        uri: url,
        type: 'POST',
        body: data,
      );

      if (!mounted) return;
      showSnackBar(
        context,
        response['msg'],
      );

      if (response['error'] == 0) {
        Navigator.pop(context, true);
      }
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
    bodyController.dispose();
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                FormText(
                  label: 'Name',
                  controller: nameController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Enter a name';
                    }

                    return null;
                  },
                ),
                FormText(
                  label: 'Body',
                  controller: bodyController,
                  maxLines: 3,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Enter a body';
                    }

                    return null;
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
      ),
    );
  }
}
