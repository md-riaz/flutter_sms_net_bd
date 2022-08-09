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
          final data = snapshot.data;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(
                  label: Text(
                    'Name',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Text',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
              rows: buildDataRows(data),
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
