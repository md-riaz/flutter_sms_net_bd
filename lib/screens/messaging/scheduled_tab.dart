// scheduled sms
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms_net_bd/services/scheduled_sms.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/widgets/confirmation.dart';

class ScheduledTab extends StatefulWidget {
  const ScheduledTab({Key? key}) : super(key: key);

  @override
  State<ScheduledTab> createState() => _ScheduledTabState();
}

class _ScheduledTabState extends State<ScheduledTab> {
  bool isLoading = false;
  Future? pageFuture;

  @override
  void initState() {
    super.initState();
    pageFuture = getScheduledSms();
  }

  Future<List> getScheduledSms() async {
    List data = [];
    try {
      setState(() {
        isLoading = true;
      });

      data = await getScheduledSMSList(context, mounted);
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return data;
  }

  void handleDelete(Map item) async {
    final delId = item['id'];

    // promt for confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        context: context,
        title: 'Delete',
        content: 'Are you sure you want to delete this?',
      ),
    );
  }

  Future<void> onRefresh() {
    return Future.delayed(Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return preloader;
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: FutureBuilder(
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
                final data = snapshot.data;

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: data.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      thickness: 1,
                      height: 1,
                    );
                  },
                  itemBuilder: (BuildContext context, int i) {
                    final Map item = data[i];
                    return ExpansionTile(
                      title: Text(item['sender_id'] ?? 'Default'),
                      leading: const Icon(Icons.access_time),
                      subtitle: Text(
                        'Recipient: ${item['message']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      children: <Widget>[
                        Column(
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Sender ID: ${item['sender_id'] ?? 'Default'}"),
                                    formSpacer,
                                    Text(
                                      "Recipients: ${item['recipient'].split(',').length}",
                                    ),
                                    formSpacer,
                                    Text(
                                      "Count: ${item['count']}",
                                    ),
                                    formSpacer,
                                    Text(
                                      "Scheduled: ${DateFormat('dd MMM yyyy, hh:mm a').format(
                                        DateTime.parse(item['scheduled']),
                                      )}",
                                    ),
                                    formSpacer,
                                    Text(
                                      "Created: ${DateFormat('dd MMM yyyy, hh:mm a').format(
                                        DateTime.parse(item['created']),
                                      )}",
                                    ),
                                    formSpacer,
                                    Text(
                                      "Message: ${item['message']}",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(
                              height: 1,
                            ),
                            IntrinsicHeight(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.timer_outlined),
                                      label: const Text(
                                        'Re-Schedule',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const VerticalDivider(
                                    thickness: 1,
                                  ),
                                  Expanded(
                                    child: TextButton.icon(
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
                );
              }

              return const Center(child: Text('No Data'));
          }
        },
      ),
    );
  }
}
