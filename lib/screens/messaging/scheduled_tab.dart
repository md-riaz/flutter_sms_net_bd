// scheduled sms
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sms_net_bd/services/scheduled_sms.dart';

class ScheduledTab extends StatefulWidget {
  const ScheduledTab({Key? key}) : super(key: key);

  @override
  State<ScheduledTab> createState() => _ScheduledTabState();
}

class _ScheduledTabState extends State<ScheduledTab> {
  List<DataRow> buildDataRows(items) {
    return <DataRow>[
      ...items.map((item) {
        return DataRow(
          cells: <DataCell>[
            DataCell(Text(item['sender_id'] ?? '')),
            DataCell(Text(
              item['message'],
              overflow: TextOverflow.ellipsis,
            )),
            DataCell(Text(item['recipient'])),
            DataCell(Text(item['count'].toString())),
            DataCell(Text(item['scheduled'])),
            DataCell(Text(item['created'])),
          ],
        );
      })
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getScheduledSMSList(context, mounted),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data;
          log(data.toString());
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
                    'Message',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Recipient',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Count',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Scheduled',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Created',
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
