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
  List<Map> senderIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPageData();
  }

  Future getPageData() async {
    final data = await getSenderIds(context, mounted);

    if (mounted) {
      setState(() {
        senderIds.addAll(List.from(data));
        isLoading = false;
      });
    }
  }

  Future<void> onRefresh() async {
    senderIds = [];
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
        itemCount: senderIds.length,
        separatorBuilder: (context, index) => const Divider(
          thickness: 1,
          height: 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          final Map item = senderIds[index];
          if (item.isEmpty) {
            return const Center(
              child: Text('No data'),
            );
          }
          return ListTile(
            title: Text(item['sender_id']),
            subtitle: Text(item['status']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 5),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(
                    DateTime.parse(item['updated'] ?? item['created']),
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
