// templates tab
import 'package:flutter/material.dart';
import 'package:sms_net_bd/services/templates.dart';

class TemplateTab extends StatefulWidget {
  const TemplateTab({Key? key}) : super(key: key);

  @override
  State<TemplateTab> createState() => _TemplateTabState();
}

class _TemplateTabState extends State<TemplateTab> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getTemplates(context, mounted),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List? data = snapshot.data as List?;

          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.separated(
                  key: Key('builder ${selected.toString()}'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data?.length ?? 0,
                  itemBuilder: (BuildContext context, int i) {
                    final Map item = data![i] as Map;
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
                                    onPressed: () {},
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
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
