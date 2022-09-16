import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sms_net_bd/services/profile.dart';
import 'package:sms_net_bd/utils/api_client.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/widgets/app_bar.dart';
import 'package:sms_net_bd/widgets/app_drawer.dart';
import 'package:sms_net_bd/widgets/form_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future? pageFuture;

  @override
  void initState() {
    pageFuture = getPageData();
    super.initState();
  }

  Future getPageData() {
    return getProfile(context, mounted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        title: 'Profile',
        mounted: mounted,
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
          future: pageFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: preloader,
                );
              case ConnectionState.done:
              default:
                if (snapshot.hasError) {
                  final error = snapshot.error;

                  return Text('🥺 $error');
                } else if (snapshot.hasData) {
                  final Map data = snapshot.data;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ProfileCard(
                          profile: data,
                        ),
                        formSpacer,
                        const PasswordCard(),
                        formSpacer,
                        SMSFooterCard(footer: data['footer']),
                      ],
                    ),
                  );
                }

                return const Center(child: Text('No Data'));
            }
          }),
    );
  }
}

class ProfileCard extends StatefulWidget {
  final Map profile;

  const ProfileCard({Key? key, required this.profile}) : super(key: key);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isLoading = false;

  Future handleProfileUpdate() async {
    try {
      setState(() => isLoading = true);

      final Map<String, String> data = {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'company': companyController.text,
        'address': addressController.text,
      };

      final response = await sendRequest(
          context: context,
          mounted: mounted,
          uri: '/user/update/',
          type: 'POST',
          body: data);

      if (!mounted) return;

      showSnackBar(context, response['msg']);
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  FormText(
                    label: 'Name',
                    initialValue: widget.profile['name'],
                    controller: nameController,
                  ),
                  FormText(
                    label: 'Email',
                    initialValue: widget.profile['email'],
                    controller: emailController,
                  ),
                  FormText(
                    label: 'Phone',
                    initialValue: widget.profile['phone'],
                    controller: phoneController,
                    readOnly: true,
                  ),
                  FormText(
                    label: 'Company',
                    initialValue: widget.profile['company'],
                    controller: companyController,
                  ),
                  FormText(
                    label: 'Address',
                    initialValue: widget.profile['address'],
                    controller: addressController,
                  ),
                  formSpacer,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          handleProfileUpdate();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordCard extends StatefulWidget {
  const PasswordCard({Key? key}) : super(key: key);

  @override
  State<PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<PasswordCard> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  Future handlePassChange() async {
    try {
      setState(() => isLoading = true);

      final Map<String, dynamic> data = {
        'current_password': oldPasswordController.text,
        'password': newPasswordController.text,
      };

      final response = await sendRequest(
        context: context,
        mounted: mounted,
        uri: '/user/update/password/',
        type: 'POST',
        body: data,
      );

      if (!mounted) return;

      showSnackBar(
        context,
        response['msg'],
      );
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Change Password',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  FormText(
                    label: 'Current Password',
                    obscureText: true,
                    controller: oldPasswordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),
                  FormText(
                    label: 'New Password',
                    obscureText: true,
                    controller: newPasswordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a new password';
                      }
                      return null;
                    },
                  ),
                  FormText(
                    label: 'Confirm Password',
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: confirmPasswordController,
                    validator: (value) {
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  formSpacer,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          handlePassChange();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(45),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Change Password'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SMSFooterCard extends StatefulWidget {
  final String? footer;

  const SMSFooterCard({Key? key, this.footer}) : super(key: key);

  @override
  State<SMSFooterCard> createState() => _SMSFooterCardState();
}

class _SMSFooterCardState extends State<SMSFooterCard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController smsFooterController = TextEditingController();
  bool isLoading = false;

  Future handleSMSFooterUpdate() async {
    try {
      setState(() => isLoading = true);

      final Map<String, dynamic> data = {
        'footer': smsFooterController.text,
      };

      final response = await sendRequest(
        context: context,
        mounted: mounted,
        uri: '/user/update/footer/',
        type: 'POST',
        body: data,
      );

      if (!mounted) return;
      showSnackBar(
        context,
        response['msg'],
      );
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    smsFooterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Padding(
        padding: EdgeInsets.all(12.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            'SMS Footer',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                FormText(
                  label: 'Footer Text',
                  controller: smsFooterController,
                  initialValue: widget.footer,
                  helperText:
                      'The footer text will be added to the end of your message. The most common use of an SMS footer is to include your Brand Name.',
                ),
                formSpacer,
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        handleSMSFooterUpdate();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Footer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}
