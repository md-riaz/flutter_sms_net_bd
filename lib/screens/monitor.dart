import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sms_net_bd/services/monitor.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/widgets/app_bar.dart';
import 'package:sms_net_bd/widgets/app_drawer.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({Key? key}) : super(key: key);

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  Future? pageFuture;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    pageFuture = getPageData();
  }

  Future getPageData() async {
    final data = await getMonitorData(context, mounted);

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        title: 'Monitor',
        mounted: mounted,
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: pageFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: preloader,
              );
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                final error = snapshot.error;

                return Text('🥺 $error');
              } else if (snapshot.hasData) {
                final Map data = snapshot.data as Map;
                log(data.toString());
                return SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Summery(monitorData: data['monitor']),
                      ],
                    ),
                  ),
                );
              }

              return const Center(child: Text('No Data'));
          }
        },
      ),
    );
  }
}

class Resources extends StatefulWidget {
  final Map data;
  const Resources({Key? key, required this.data}) : super(key: key);

  @override
  State<Resources> createState() => _ResourcesState();
}

class _ResourcesState extends State<Resources> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resource Usage',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        formSpacer,
      ],
    );
  }
}

class Summery extends StatelessWidget {
  final Map monitorData;

  const Summery({Key? key, required this.monitorData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SMS Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        formSpacer,
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.43,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Requests',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  formSpacer,
                  formSpacer,
                  Text(
                    monitorData['sms_requests'].toString(),
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.blue.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.43,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  formSpacer,
                  formSpacer,
                  Text(
                    monitorData['pending'].toString(),
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.purple.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width * 0.3,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sent',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  formSpacer,
                  Text(
                    monitorData['sent'].toString(),
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.green.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.43,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Failed',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  formSpacer,
                  formSpacer,
                  Text(
                    monitorData['failed'].toString(),
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.43,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Errors',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  formSpacer,
                  formSpacer,
                  Text(
                    monitorData['errors'].toString(),
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.orange.shade400,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
