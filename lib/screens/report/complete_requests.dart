import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms_net_bd/services/requests.dart';
import 'package:sms_net_bd/utils/constants.dart';

class CompleteRequests extends StatefulWidget {
  const CompleteRequests({super.key});

  @override
  State<CompleteRequests> createState() => _CompleteRequestsState();
}

class _CompleteRequestsState extends State<CompleteRequests> {
  final controller = ScrollController();
  List items = [];
  bool hasMore = true;
  int page = 1;
  bool isLoading = false;
  Map<String, dynamic>? queryParams = {};

  @override
  void initState() {
    super.initState();
    queryParams!['page'] = page.toString();
    getPageData();
    // listen to the scroll and load more data when the user reaches the end of the list
    controller.addListener(() {
      if (controller.offset == controller.position.maxScrollExtent) {
        getPageData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.separated(
        controller: controller,
        itemCount: items.length + 1,
        separatorBuilder: (context, index) => const Divider(
          thickness: 1,
          height: 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          if (index < items.length) {
            final item = items[index];

            if (item.isEmpty) {
              return const Center(
                child: Text('No data'),
              );
            }

            return ExpansionTile(
              leading: const SizedBox(
                height: double.infinity,
                child: Icon(Icons.messenger_outline_rounded),
              ),
              title: item['sender_id'] != null
                  ? Text(item['sender_id'])
                  : const Text(
                      'Default',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
              subtitle: Text('Sent/Failed: ${item['sent']}/${item['failed']}'),
              trailing: Text(
                DateFormat('dd MMM yyyy').format(
                  DateTime.parse(item['datetime']),
                ),
              ),
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const Text(
                                    'Request ID: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(item['Request_ID'].toString()),
                                ]),
                                Row(
                                  children: [
                                    const Text(
                                      'Sender ID: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (item['sender_id'] != null)
                                      Text(item['sender_id'])
                                    else
                                      const Text(
                                        'Default',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                        ),
                                      )
                                  ],
                                )
                              ],
                            ),
                            formSpacer,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const Text(
                                    'Length: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(item['msg_length'].toString()),
                                ]),
                                Row(
                                  children: [
                                    const Text(
                                      'Sender ID: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (item['sender_id'] != null)
                                      Text(item['sender_id'])
                                    else
                                      const Text(
                                        'Default',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                        ),
                                      )
                                  ],
                                )
                              ],
                            ),
                            formSpacer,
                            const Text(
                              'Message',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(item['message'].toString()),
                            formSpacer,
                            const Text(
                              'Sent/Failed',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text('${item['sent']}/${item['failed']}'),
                            formSpacer,
                            const Text(
                              'Charge',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text('${item['charge']}'),
                            formSpacer,
                            const Text(
                              'Status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text('${item['status']}'),
                            formSpacer,
                            const Text(
                              'DateTime',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(DateFormat('dd MMM yyyy hh:mm a').format(
                              DateTime.parse(item['datetime']),
                            )),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: hasMore
                ? preloader
                : const Center(
                    child: Text(
                    'No more data to load',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
          );
        },
      ),
    );
  }

  Future getPageData() async {
    if (isLoading) {
      return;
    }
    isLoading = true;

    if (queryParams!['from'] == null) {
      queryParams!['from'] = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1000)));
      queryParams!['to'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }

    final data = await getCompleteRequests(context, mounted, queryParams);

    if (mounted) {
      setState(() {
        page++;
        isLoading = false;

        if (data['items'].length < data['item_limit']) {
          hasMore = false;
        }

        items.addAll(data['items']);
      });
    }
  }

  Future refresh() async {
    setState(() {
      isLoading = false;
      hasMore = false;
      page = 0;
      items.clear();
    });

    await getPageData();
  }
}
