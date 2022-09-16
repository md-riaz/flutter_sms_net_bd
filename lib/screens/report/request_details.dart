import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms_net_bd/services/requests.dart';
import 'package:sms_net_bd/utils/constants.dart';

class CompleteRequestDetails extends StatefulWidget {
  final String requestID;

  const CompleteRequestDetails({super.key, required this.requestID});

  @override
  State<CompleteRequestDetails> createState() => _CompleteRequestDetailsState();
}

class _CompleteRequestDetailsState extends State<CompleteRequestDetails> {
  final controller = ScrollController();
  List items = [];
  bool hasMore = true;
  int page = 1;
  bool isLoading = false;
  Map<String, dynamic> queryParams = {
    'page': '1',
  };

  @override
  void initState() {
    super.initState();

// get request details
    queryParams['request_id'] = widget.requestID;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView.separated(
          controller: controller,
          itemCount: items.length + 1,
          separatorBuilder: (context, index) => const Divider(
            thickness: 1,
            height: 1,
          ),
          itemBuilder: (BuildContext context, int index) {
            if (isLoading) {
              return preloader;
            }

            if (index < items.length) {
              final item = items[index];

              if (item.isEmpty) {
                return const Center(
                  child: Text('No data'),
                );
              }

              return ExpansionTile(
                leading: SizedBox(
                  height: double.infinity,
                  child:
                      Icon(item['status'] == 'Sent' ? Icons.done : Icons.close),
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
                subtitle: Text(
                  '${item['number']}',
                ),
                trailing: Text(
                  DateFormat('dd MMM yyyy').format(
                    DateTime.parse(item['updated']),
                  ),
                ),
                children: <Widget>[
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
                                Text(item['req_id'].toString()),
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
                                  'Number: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(item['number'].toString()),
                              ]),
                              Row(
                                children: [
                                  const Text(
                                    'Count: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('${item['count']}')
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
                                  'Charge: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(item['charge'].toString()),
                              ]),
                              Row(
                                children: [
                                  const Text(
                                    'Status: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('${item['status']}')
                                ],
                              )
                            ],
                          ),
                          formSpacer,
                          Text(item['message'].toString()),
                          formSpacer,
                          const Text(
                            'DateTime',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(DateFormat('dd MMM yyyy hh:mm a').format(
                            DateTime.parse(item['updated']),
                          )),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: !hasMore
                  ? const Center(
                      child: Text(
                      'No more data to load',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
                  : preloader,
            );
          },
        ),
      ),
    );
  }

  Future getPageData() async {
    if (isLoading) {
      return;
    }

    isLoading = true;

    if (queryParams['from'] == null) {
      queryParams['from'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
      queryParams['to'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
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
