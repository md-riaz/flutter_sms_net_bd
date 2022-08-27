// sender id tab
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms_net_bd/services/senderid.dart';
import 'package:sms_net_bd/utils/constants.dart';

class SenderIdTab extends StatefulWidget {
  const SenderIdTab({Key? key}) : super(key: key);

  @override
  State<SenderIdTab> createState() => _SenderIdTabState();
}

class _SenderIdTabState extends State<SenderIdTab> {
  Future? pageFuture;
  List<Map> SenderIDs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPageData();
  }

  Future getPageData() async {
    final data = await getSenderIds(context, mounted);

    setState(() {
      SenderIDs.addAll(List.from(data));
      isLoading = false;
    });
  }

  Future<void> onRefresh() async {
    SenderIDs = [];
    await getPageData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return preloader;
    }

    return RefreshIndicator(
      onRefresh: (() => onRefresh()),
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: SenderIDs.length,
        separatorBuilder: (context, index) => const Divider(
          thickness: 1,
          height: 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          final Map item = SenderIDs[index];

          return ListTile(
            title: Text(item[index]!['sender_id']),
            subtitle: Text(item[index]!['status']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 5),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(
                    DateTime.parse(
                        item[index]['updated'] ?? item[index]['created']),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
