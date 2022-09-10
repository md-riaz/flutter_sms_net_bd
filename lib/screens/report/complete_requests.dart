import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms_net_bd/services/requests.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/widgets/form_text.dart';

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
  Map<String, dynamic> queryParams = {
    'page': '1',
  };

  @override
  void initState() {
    super.initState();
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
    return Column(
      children: [
        CompleteRequestFilter(
          changeRequestParams: changeRequestParams,
          handleSearch: handleSearch,
        ),
        const Divider(),
        Expanded(
          flex: 1,
          child: RefreshIndicator(
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
                  // todo need to use expension panel list
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
                    subtitle:
                        Text('Sent/Failed: ${item['sent']}/${item['failed']}'),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                            'Sent/Failed: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                              '${item['sent']}/${item['failed']}')
                                        ],
                                      )
                                    ],
                                  ),
                                  formSpacer,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.remove_red_eye_outlined),
                            label: const Text('View Details'),
                          ),
                        ],
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
        ),
      ],
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

  void changeRequestParams(DateTime from, DateTime to, String search) {
    setState(() {
      queryParams['from'] = DateFormat('yyyy-MM-dd').format(from);
      queryParams['to'] = DateFormat('yyyy-MM-dd').format(to);
      queryParams['search'] = search;
    });
  }

  void handleSearch() {
    refresh();
  }
}

class CompleteRequestFilter extends StatefulWidget {
  final Function(DateTime, DateTime, String) changeRequestParams;
  final void Function()? handleSearch;

  const CompleteRequestFilter(
      {super.key,
      required this.changeRequestParams,
      required this.handleSearch});

  @override
  State<CompleteRequestFilter> createState() => _CompleteRequestFilterState();
}

class _CompleteRequestFilterState extends State<CompleteRequestFilter> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  String initialDate =
      '${DateFormat('dd MMM yyyy').format(DateTime.now())} - ${DateFormat('dd MMM yyyy').format(DateTime.now())}';

  TextEditingController dateRangeController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    dateRangeController.text = initialDate;
    super.initState();
  }

  @override
  void dispose() {
    dateRangeController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const SizedBox(
        height: double.infinity,
        child: Icon(Icons.search),
      ),
      title: const Text('Search Filter'),
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            child: Column(
              children: [
                FormText(
                  label: 'Date Range',
                  controller: dateRangeController,
                  bordered: false,
                  suffixIcon: const Icon(Icons.calendar_today),
                  readOnly: true,
                  onTap: handleDateRange,
                ),
                FormText(
                  label: 'Search',
                  controller: searchController,
                  hintText: 'Search by ID, Sender ID, Message',
                  onChanged: (value) {
                    widget.changeRequestParams(
                      startDate,
                      endDate,
                      value,
                    );
                  },
                ),
                formSpacer,
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          onPressed: resetParams,
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.handleSearch,
                          child: const Text('Search'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  handleDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      lastDate: DateTime.now(),
      firstDate: DateTime(2000),
      initialDateRange: DateTimeRange(
        start: startDate,
        end: endDate,
      ),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        dateRangeController.text =
            '${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}';
      });

      widget.changeRequestParams(
        startDate,
        endDate,
        searchController.text,
      );
    }
  }

  void resetParams() {
    startDate = DateTime.now();
    endDate = DateTime.now();
    dateRangeController.text = initialDate;
    searchController.clear();
    widget.changeRequestParams(
      startDate,
      endDate,
      searchController.text,
    );
  }
}
