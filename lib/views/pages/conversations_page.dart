import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/message_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/customer.dart';
import 'package:jdarwish_dashboard_web/shared/navigate_helpers.dart';

import 'messages_page.dart';

class ConversationsPage extends StatefulWidget {
  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversations"),
      ),
      body: StreamBuilder<List<Customer>>(
        stream: MessageBloc().customerStream,
        initialData: MessageBloc().users,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            child: snapshot.hasData
                ? ListView(
                    children: [
                      for (Customer customer in MessageBloc().users)
                        Column(
                          children: [
                            ListTile(
                              title: Text(customer.email ?? 'No email on file'),
                              subtitle: customer.unread > 0
                                  ? Text('${customer.unread} New Message(s)')
                                  : null,
                              leading: Icon(
                                Icons.account_circle_outlined,
                                size: 48,
                              ),
                              onTap: () =>
                                  Get.toNamed('/messages', arguments: customer),
                            ),
                            Divider(),
                          ],
                        )
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
            duration: Duration(milliseconds: 300),
          );
        },
      ),
    );
  }
}
