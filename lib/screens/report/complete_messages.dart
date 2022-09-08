import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms_net_bd/services/messages.dart';

class CompleteMessages extends StatefulWidget {
  const CompleteMessages({super.key});

  @override
  State<CompleteMessages> createState() => _CompleteMessagesState();
}

class _CompleteMessagesState extends State<CompleteMessages> {
  final controller = ScrollController();
  List items = [];
  bool hasMore = true;
  int page = 1;
  bool isLoading = false;
  Map<String, dynamic> queryParams = {
    'page': '1',
  };

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future getPageData() async {
    if (isLoading) {
      return;
    }

    isLoading = true;

    if (queryParams['from'] == null) {
      queryParams['from'] = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1000)));
      queryParams['to'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }

    final data = await getCompletedMessages(context, mounted, queryParams);

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
