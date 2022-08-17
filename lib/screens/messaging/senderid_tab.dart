// sender id tab
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

  @override
  void initState() {
    super.initState();
    pageFuture = getApprovedSenderIds(context, mounted);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: pageFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return preloader;
          case ConnectionState.done:
          default:
            if (snapshot.hasError) {
              final error = snapshot.error;

              return Text('🥺 $error');
            } else if (snapshot.hasData) {
              final List? data = snapshot.data;

              return SingleChildScrollView(
                child: SlidableAutoCloseBehavior(
                  child: ListView.separated(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: data!.length,
                    separatorBuilder: (context, index) => const Divider(
                      thickness: 1,
                      height: 1,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Slidable(
                        key: ValueKey(
                            data[index] != null ? data[index]['id'] as int : 0),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (BuildContext context) {
                                // show alert that delete page will come soon
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete'),
                                    content: const Text(
                                        'Delete page will come soon'),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(data[index]!['sender_id']),
                          subtitle: Text(data[index]!['status']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time),
                              const SizedBox(width: 5),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(
                                  DateTime.parse(data[index]!['created']),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
            return const Center(child: Text('No Data'));
        }
      },
    );
  }
}
