// sender id tab
import 'package:flutter/material.dart';
import 'package:sms_net_bd/services/senderid.dart';

class SenderIdTab extends StatefulWidget {
  const SenderIdTab({Key? key}) : super(key: key);

  @override
  State<SenderIdTab> createState() => _SenderIdTabState();
}

class _SenderIdTabState extends State<SenderIdTab> {
  List<DataRow> buildDataRows(items) {
    return <DataRow>[
      ...items.map((item) {
        return DataRow(
          cells: <DataCell>[
            DataCell(Text(item['sender_id'])),
            DataCell(Text(item['status'])),
            DataCell(Text(item['created'])),
          ],
        );
      })
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getApprovedSenderIds(context, mounted),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(
                  label: Text(
                    'Sender ID',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Requested',
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
