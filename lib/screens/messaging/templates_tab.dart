// templates tab
import 'package:flutter/material.dart';
import 'package:sms_net_bd/screens/messaging/pages/template_form.dart';
import 'package:sms_net_bd/services/templates.dart';
import 'package:sms_net_bd/utils/constants.dart';
import 'package:sms_net_bd/widgets/confirmation.dart';

class TemplateTab extends StatefulWidget {
  const TemplateTab({Key? key}) : super(key: key);

  @override
  State<TemplateTab> createState() => _TemplateTabState();
}

class _TemplateTabState extends State<TemplateTab> {
  List<Map> templates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPageData();
  }

  Future getPageData() async {
    final data = await getTemplates(context, mounted);

    if (mounted) {
      setState(() {
        templates.addAll(List.from(data));
        isLoading = false;
      });
    }
  }

  void handleDelete(item) async {
    final delId = item['id'];

    // promt for confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        context: context,
        title: 'Delete Template',
        content: 'Are you sure you want to delete this template?',
      ),
    );

    if (confirm == true) {
      setState(() {
        isLoading = true;
      });
      if (!mounted) return;
      final resp = await deleteTemplate(context, mounted, delId);

      if (resp == true) {
        setState(() {
          templates = [];
        });
        await getPageData();
      }
    }
  }

  Future<void> onRefresh() async {
    templates = [];
    await getPageData();
  }

  Future handleEdit(item) async {
    final bool? updated =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TemplateForm(
        title: 'Edit Template',
        tempId: item['id'],
        tempName: item['name'],
        tempBody: item['text'],
      );
    }));

    if (updated == true) {
      setState(() {
        isLoading = true;
        templates = [];
        getPageData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return preloader;
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: templates.length,
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            thickness: 1,
            height: 1,
          );
        },
        itemBuilder: (BuildContext context, int i) {
          final Map item = templates[i];
          if (item.isEmpty) {
            return const Center(
              child: Text('No data'),
            );
          }
          return ExpansionTile(
            title: Text(item['name']),
            children: <Widget>[
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 16, left: 16, bottom: 16),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(item['text'])),
                  ),
                  const Divider(
                    height: 1,
                  ),
                  IntrinsicHeight(
                    child: ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      buttonPadding: const EdgeInsets.all(0),
                      children: [
                        TextButton.icon(
                          onPressed: () => handleEdit(item),
                          icon: const Icon(Icons.edit),
                          label: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          thickness: 0.5,
                        ),
                        TextButton.icon(
                          onPressed: () => handleDelete(item),
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
                      ],
                    ),
                  )
                ],
              ),
              // add more data that you want like this
            ],
          );
        },
      ),
    );
  }
}
