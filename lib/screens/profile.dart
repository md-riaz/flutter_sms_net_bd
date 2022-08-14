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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: appBar(
        context,
        title: 'Profile',
        mounted: mounted,
      ),
      drawer: appDrawer(context, mounted),
      body: SingleChildScrollView(
        child: Column(
          children: const [ProfileCard(), PasswordCard()],
        ),
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  Future? pageFuture;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    pageFuture = getPageData();
    super.initState();
  }

  Future getPageData() {
    return getProfile(context, mounted);
  }

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
    return FutureBuilder(
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
                              initialValue: data['name'],
                              controller: nameController,
                            ),
                            FormText(
                              label: 'Email',
                              initialValue: data['email'],
                              controller: emailController,
                            ),
                            FormText(
                              label: 'Phone',
                              initialValue: data['phone'],
                              controller: phoneController,
                              readOnly: true,
                            ),
                            FormText(
                              label: 'Company',
                              initialValue: data['company'],
                              controller: companyController,
                            ),
                            FormText(
                              label: 'Address',
                              initialValue: data['address'],
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

            return const Center(child: Text('No Data'));
        }
      },
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
