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

  @override
  void initState() {
    super.initState();
    pageFuture = getSenderIds(context, mounted);
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
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: data!.length,
                  separatorBuilder: (context, index) => const Divider(
                    thickness: 1,
                    height: 1,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(data[index]!['sender_id']),
                      subtitle: Text(data[index]!['status']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat('dd MMM yyyy, hh:mm a').format(
                              DateTime.parse(data[index]['updated'] ??
                                  data[index]['created']),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
            return const Center(child: Text('No Data'));
        }
      },
    );
  }
}
