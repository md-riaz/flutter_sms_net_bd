// templates tab
import 'package:flutter/material.dart';
import 'package:sms_net_bd/services/templates.dart';

class TemplateTab extends StatefulWidget {
  const TemplateTab({Key? key}) : super(key: key);

  @override
  State<TemplateTab> createState() => _TemplateTabState();
}

class _TemplateTabState extends State<TemplateTab> {
  List<DataRow> buildDataRows(items) {
    return <DataRow>[
      ...items.map((item) {
        return DataRow(
          cells: <DataCell>[
            DataCell(Text(
              item['name'],
              overflow: TextOverflow.ellipsis,
            )),
            DataCell(Text(
              item['text'],
              overflow: TextOverflow.ellipsis,
            )),
          ],
        );
      })
    ];
  }

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
                ...data!.map((item) {
                  return Card(
                    child: ExpansionTile(
                      title: Text(item['name']),
                      children: <Widget>[
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 16, left: 16),
                              child: Text(item['text']),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: const Icon(Icons.edit),
                                  onPressed: () {},
                                ),
                                TextButton(
                                  child: const Icon(Icons.delete),
                                  onPressed: () {},
                                ),
                              ],
                            )
                          ],
                        ),
                        // add more data that you want like this
                      ],
                    ),
                  );
                }),
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
