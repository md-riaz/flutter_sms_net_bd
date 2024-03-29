import 'package:flutter/material.dart';
import 'package:sms_net_bd/screens/phonebook/contacts_tab.dart';
import 'package:sms_net_bd/screens/phonebook/groups_tab.dart';
import 'package:sms_net_bd/screens/phonebook/pages/contact_form.dart';
import 'package:sms_net_bd/screens/phonebook/pages/group_form.dart';
import 'package:sms_net_bd/screens/phonebook/widgets/bottom_nav.dart';
import 'package:sms_net_bd/widgets/app_bar.dart';
import 'package:sms_net_bd/widgets/app_drawer.dart';

class PhonebookScreen extends StatefulWidget {
  const PhonebookScreen({Key? key}) : super(key: key);

  @override
  State<PhonebookScreen> createState() => _PhonebookScreenState();
}

class _PhonebookScreenState extends State<PhonebookScreen> {
  int currentIndex = 0;

  final List<StatefulWidget> screens = [
    const ContactsTab(),
    const GroupsTab(),
  ];

  Future handleAddButton() async {
    if (currentIndex == 0) {
      final bool? success = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return const ContactForm(
            title: 'Add Contact',
          );
        }),
      );

      if (success != null && success) {
        setState(() {
          currentIndex = 1;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            currentIndex = 0;
          });
        });
      }
    } else {
      final bool? success = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return const GroupForm(
            title: 'Add Group',
          );
        }),
      );

      if (success != null && success) {
        setState(() => currentIndex = 0);

        Future.delayed(
          const Duration(milliseconds: 500),
          () => setState(() => currentIndex = 1),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        title: 'Phonebook',
        mounted: mounted,
      ),
      drawer: const AppDrawer(),
      body: screens[currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: handleAddButton,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: appBottomBar(
        context,
        currentIndex,
        (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
