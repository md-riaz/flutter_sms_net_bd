import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:sms_net_bd/screens/errors.dart';
import 'package:sms_net_bd/services/monitor.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/widgets/app_bar.dart';
import 'package:sms_net_bd/widgets/app_drawer.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({Key? key}) : super(key: key);

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen>
    with TickerProviderStateMixin {
  Future? pageFuture;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    pageFuture = getPageData();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      if (mounted) {
        setState(() {
          pageFuture = getPageData();
        });
      }
    });
  }

  Future getPageData() async {
    if (mounted) {
      _controller.repeat();
      final data = await getMonitorData(context, mounted);
      _controller.stop();
      return data;
    }

    return null;
  }

// Create a controller
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );

// Create an animation with value of type "double"
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

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

            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                final error = snapshot.error;

                return Text('🥺 $error');
              } else if (snapshot.hasData) {
                final Map data = snapshot.data as Map;

                return SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Resources(
                          cpu: data['monitor']['cpu'],
                          ram: data['monitor']['ram'],
                          disk: data['monitor']['disk'],
                        ),
                        formSpacer,
                        Summery(monitorData: data['monitor']),
                        formSpacer,
                        LastRequests(lastRequests: data['last_requests']),
                      ],
                    ),
                  ),
                );
              }

              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: preloader,
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            pageFuture = getPageData();
          });
        },
        child: RotationTransition(
          turns: _animation,
          child: const Icon(Icons.rotate_right_rounded),
        ),
      ),
    );
  }
}

class Resources extends StatelessWidget {
  final Map cpu;
  final Map disk;
  final Map ram;

  const Resources({
    Key? key,
    required this.cpu,
    required this.disk,
    required this.ram,
  }) : super(key: key);

  @override
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
        Wrap(
          runSpacing: 12,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.cyan.shade50,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CPU',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      formSpacer,
                      Text(
                        'CPU Core: ${cpu['core']}',
                        style: TextStyle(
                          color: Colors.cyan.shade400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Free: ${cpu['free']}%',
                        style: TextStyle(
                          color: Colors.cyan.shade400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 90,
                    width: 90,
                    child: LiquidCircularProgressIndicator(
                      value: cpu['usage'] / 100, // Defaults to 0.5.
                      valueColor: AlwaysStoppedAnimation(
                        Colors.cyan.shade200,
                      ), // Defaults to the current Theme's accentColor.
                      backgroundColor: Colors
                          .white, // Defaults to the current Theme's backgroundColor.
                      borderColor: Colors.cyan.shade300,
                      borderWidth: 3.0,
                      direction: Axis.vertical,
                      // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                      center: Text("${cpu['usage']}%"), //text inside it
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RAM',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      formSpacer,
                      Text(
                        'Total: ${ram['total']}',
                        style: TextStyle(
                          color: Colors.pink.shade400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Free: ${ram['free']}',
                        style: TextStyle(
                          color: Colors.pink.shade400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 90,
                    width: 90,
                    child: LiquidCircularProgressIndicator(
                      value: ram['usage'] / 100, // Defaults to 0.5.
                      valueColor: AlwaysStoppedAnimation(
                        Colors.pink.shade100,
                      ), // Defaults to the current Theme's accentColor.
                      backgroundColor: Colors
                          .white, // Defaults to the current Theme's backgroundColor.
                      borderColor: Colors.pink.shade300,
                      borderWidth: 3.0,
                      direction: Axis.vertical,
                      // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                      center: Text("${ram['used']}"), //text inside it
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DISK',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      formSpacer,
                      Text(
                        'Total: ${disk['total']}',
                        style: TextStyle(
                          color: Colors.teal.shade400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Free: ${disk['free']}',
                        style: TextStyle(
                          color: Colors.teal.shade400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 90,
                    width: 90,
                    child: LiquidCircularProgressIndicator(
                      value: disk['usage'] / 100, // Defaults to 0.5.
                      valueColor: AlwaysStoppedAnimation(
                        Colors.teal.shade200,
                      ), // Defaults to the current Theme's accentColor.
                      backgroundColor: Colors
                          .white, // Defaults to the current Theme's backgroundColor.
                      borderColor: Colors.teal.shade300,
                      borderWidth: 3.0,
                      direction: Axis.vertical,
                      // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                      center: Text("${disk['used']}"), //text inside it
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class Summery extends StatelessWidget {
  final Map monitorData;

  Summery({Key? key, required this.monitorData}) : super(key: key);

  final NumberFormat formatter = NumberFormat.decimalPattern('en_us');

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
                    formatter.format(monitorData['sms_requests']),
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
                    formatter.format(monitorData['pending']),
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
                    formatter.format(monitorData['sent']),
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
                    formatter.format(monitorData['failed']),
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MonitorErrorScreen(),
                ),
              ),
              child: Container(
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
                      formatter.format(monitorData['errors']),
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.orange.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class LastRequests extends StatelessWidget {
  final List lastRequests;
  const LastRequests({super.key, required this.lastRequests});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last 10 Requests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        formSpacer,
        ...lastRequests
            .map(
              (item) => Column(
                children: [
                  ExpansionTile(
                    leading: SizedBox(
                      height: double.infinity,
                      child: Icon((item['status'] == 'Complete')
                          ? Icons.done
                          : (item['status'] == 'Processing')
                              ? Icons.work_outline
                              : Icons.pending),
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
                        'Sent/Failed: ${item['count'] - item['failed']}/${item['failed']}'),
                    trailing: Text(
                      DateFormat('dd MMM yyyy hh:mm a').format(
                        DateTime.parse(item['created']),
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
                                            '${item['count'] - item['failed']}/${item['failed']}',
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
                                          Text(item['status'] == 1
                                              ? 'Complete'
                                              : 'Processing')
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
                                    DateTime.parse(item['created']),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const Divider(),
                ],
              ),
            )
            .toList(),
      ],
    );
  }
}
