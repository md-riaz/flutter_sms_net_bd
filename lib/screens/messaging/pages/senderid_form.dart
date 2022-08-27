import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sms_net_bd/services/senderid.dart';
import 'package:sms_net_bd/utils/api_client.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/widgets/form_text.dart';

class SenderIdForm extends StatefulWidget {
  const SenderIdForm({Key? key}) : super(key: key);

  @override
  State<SenderIdForm> createState() => _SenderIdFormState();
}

class _SenderIdFormState extends State<SenderIdForm> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final TextEditingController senderidController = TextEditingController();

  Future handleSubmit() async {
    try {
      setState(() => isLoading = true);

      final Map resp =
          await addSenderId(context, mounted, senderidController.text);
      if (!mounted) return false;

      showSnackBar(context, resp['msg']);

      if (resp['error'] == 0) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      log(e.toString());
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    senderidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request For Sender ID'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                FormText(
                  label: 'Sender ID',
                  controller: senderidController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Enter a sender id';
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
                            primary: Colors.grey,
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
