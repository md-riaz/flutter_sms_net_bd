import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
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
                          CPU: data['monitor']['cpu'],
                          RAM: data['monitor']['ram'],
                          Disk: data['monitor']['disk'],
                        ),
                        formSpacer,
                        Summery(monitorData: data['monitor']),
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
  final Map CPU;
  final Map Disk;
  final Map RAM;

  const Resources({
    Key? key,
    required this.CPU,
    required this.Disk,
    required this.RAM,
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
                        'CPU Core: ${CPU['core']}',
                        style: TextStyle(
                          color: Colors.cyan.shade400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Free: ${CPU['free']}%',
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
                      value: CPU['usage'] / 100, // Defaults to 0.5.
                      valueColor: AlwaysStoppedAnimation(
                        Colors.cyan.shade200,
                      ), // Defaults to the current Theme's accentColor.
                      backgroundColor: Colors
                          .white, // Defaults to the current Theme's backgroundColor.
                      borderColor: Colors.cyan.shade300,
                      borderWidth: 3.0,
                      direction: Axis.vertical,
                      // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                      center: Text("${CPU['usage']}%"), //text inside it
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
                        'Total: ${RAM['total']}',
                        style: TextStyle(
                          color: Colors.pink.shade400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Free: ${RAM['free']}',
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
                      value: RAM['usage'] / 100, // Defaults to 0.5.
                      valueColor: AlwaysStoppedAnimation(
                        Colors.pink.shade100,
                      ), // Defaults to the current Theme's accentColor.
                      backgroundColor: Colors
                          .white, // Defaults to the current Theme's backgroundColor.
                      borderColor: Colors.pink.shade300,
                      borderWidth: 3.0,
                      direction: Axis.vertical,
                      // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                      center: Text("${RAM['used']}"), //text inside it
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
                        'Total: ${Disk['total']}',
                        style: TextStyle(
                          color: Colors.teal.shade400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Free: ${Disk['free']}',
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
                      value: Disk['usage'] / 100, // Defaults to 0.5.
                      valueColor: AlwaysStoppedAnimation(
                        Colors.teal.shade200,
                      ), // Defaults to the current Theme's accentColor.
                      backgroundColor: Colors
                          .white, // Defaults to the current Theme's backgroundColor.
                      borderColor: Colors.teal.shade300,
                      borderWidth: 3.0,
                      direction: Axis.vertical,
                      // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                      center: Text("${Disk['used']}"), //text inside it
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
                    formatter.format(monitorData['errors']),
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
