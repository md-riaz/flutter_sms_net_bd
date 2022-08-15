// templates tab
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sms_net_bd/services/templates.dart';
import 'package:sms_net_bd/widgets/confirmation.dart';

class TemplateTab extends StatefulWidget {
  const TemplateTab({Key? key}) : super(key: key);

  @override
  State<TemplateTab> createState() => _TemplateTabState();
}

class _TemplateTabState extends State<TemplateTab> {
  List<Map> templates = [];

  @override
  void initState() {
    super.initState();
    getPageData();
  }

  Future getPageData() async {
    final data = await getTemplates(context, mounted);

    setState(() {
      templates.addAll(List.from(data));
    });
  }

  void handleDelete(item) async {
    final delId = item['id'];

    // promt for confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        context: context,
        title: 'Delete Template',
        content: 'Are you sure you want to delete this template?',
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final resp = await deleteTemplate(context, mounted, delId);

      if (resp == true) {
        setState(() {
          templates.removeWhere((item) => item['id'] == delId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.separated(
            key: const ValueKey(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: templates.length,
            itemBuilder: (BuildContext context, int i) {
              final Map item = templates[i];
              log(templates.toString());
              return ExpansionTile(
                title: Text(item['name']),
                children: <Widget>[
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 16, left: 16, bottom: 16),
                        child: Text(item['text']),
                      ),
                      const Divider(
                        height: 1,
                      ),
                      IntrinsicHeight(
                        child: ButtonBar(
                          alignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          buttonPadding: const EdgeInsets.all(0),
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit),
                              label: const Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            const VerticalDivider(
                              thickness: 0.5,
                            ),
                            TextButton.icon(
                              onPressed: () {
                                handleDelete(item);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  // add more data that you want like this
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                thickness: 1,
                height: 1,
              );
            },
          ),
        ],
      ),
    );
  }
}
