import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms_net_bd/services/monitor_errors.dart';
import 'package:sms_net_bd/utils/constants.dart';

class MonitorErrorScreen extends StatefulWidget {
  const MonitorErrorScreen({super.key});

  @override
  State<MonitorErrorScreen> createState() => _MonitorErrorScreenState();
}

class _MonitorErrorScreenState extends State<MonitorErrorScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor Errors'),
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
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: preloader,
              );
            }

            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('No data'),
                ),
              );
            }

            if (index < items.length) {
              final item = items[index];
              // todo need to use expension panel list
              return ExpansionTile(
                leading: const SizedBox(
                  height: double.infinity,
                  child: Icon(Icons.warning_outlined),
                ),
                title: Text('${item['account']} (${item['id']})'),
                subtitle: Text(
                  '${item['error']}',
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  DateFormat('dd MMM yyyy hh:mm a').format(
                    DateTime.parse(item['created']),
                  ),
                ),
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Error: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(item['error'].toString()),
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

    final data = await getErrorMessages(context, mounted, queryParams);

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
