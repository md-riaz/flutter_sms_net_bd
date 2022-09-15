import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sms_net_bd/screens/phonebook/pages/contact_form.dart';
import 'package:sms_net_bd/services/contacts.dart';
import 'package:sms_net_bd/utils/api_client.dart';
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
          if (isLoading) {
            return const Padding(
              padding: EdgeInsets.all(32.0),
              child: preloader,
            );
          }

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
                    onPressed: (BuildContext context) async {
                      final edit = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactForm(
                            title: 'Edit Contact',
                            formData: item,
                          ),
                        ),
                      );

                      if (edit != null) {
                        refresh();
                      }
                    },
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (BuildContext context) {
                      handleDelete(context, item);
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: ListTile(
                leading: const SizedBox(
                  height: double.infinity,
                  child: Icon(Icons.person),
                ),
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

  void handleDelete(BuildContext context, Map item) {
    // ask if delete should be performed
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure want to delete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.grey),
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (!mounted) return;
              final deleted = await deleteContact(
                context,
                mounted,
                item['id'],
              );

              if (!mounted) return;
              if (deleted) {
                showSnackBar(context, 'Deleted successfully');
                refresh();
              }

              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future getPageData() async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

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
}
