import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sms_net_bd/services/contacts.dart';
import 'package:sms_net_bd/utils/constants.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({Key? key}) : super(key: key);

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  final controller = ScrollController();
  List items = [];
  bool hasMore = true;
  int page = 1;
  bool isLoading = false;

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

  Future getPageData() async {
    if (isLoading) {
      return;
    }
    isLoading = true;
    final data = await getContacts(context, mounted, {'page': page.toString()});

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

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
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

            return Slidable(
              key: const ValueKey(0),

              // The end action pane is the one at the right or the bottom side.
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (BuildContext context) {
                      // show alert that edit page will come soon
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Edit'),
                          content: const Text('Edit page will come soon'),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (BuildContext context) {
                      // show alert that delete page will come soon
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete'),
                          content: const Text('Delete page will come soon'),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: ListTile(
                title: item['name'].toString().isNotEmpty
                    ? Text(item['name'])
                    : const Text(
                        'Unknown',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                subtitle: Text(item['email'] ?? ''),
                trailing: Text(item['number'].toString()),
              ),
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
}
