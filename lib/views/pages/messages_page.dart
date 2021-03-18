import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/message_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/user_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/customer.dart';
import 'package:jdarwish_dashboard_web/shared/models/message.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

import 'conversations_page.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String newMessage;

  List<Conversation> conversations;
  Conversation selectedConversation;

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  bool showDrawer = false;
  Customer customer = Get.arguments;
  TextEditingController _controller;

  @override
  void initState() {
    if (UserBloc().isAdmin) {
      if (customer == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed('/conversations');
        });
      } else {
        MessageBloc().loadMessagesFromCustomer(customer.id);
        MessageBloc().markAllAsRead(customer);
      }
    } else {
      MessageBloc().markAllAsRead(null);
    }

    this._controller = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      appBar: AppBar(
        title: Image.network(AppBloc().logoUrl, height: 56),
        toolbarHeight: kToolbarHeight + 24,
        elevation: 2.0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (showDrawer)
            IconButton(
              icon: Icon(Icons.people_alt_outlined),
              onPressed: () => _drawerKey.currentState.openEndDrawer(),
            ),
        ],
      ),
      endDrawer: showDrawer
          ? Drawer(
              child: ListView(
              children: [
                for (Conversation conversation in conversations)
                  ListTile(
                    title: Text(conversation.toId),
                    onTap: () {
                      setState(() => this.selectedConversation = conversation);
                      Navigator.of(context).pop();
                    },
                  )
              ],
            ))
          : null,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: StreamBuilder<List<Conversation>>(
                stream: MessageBloc().conversationStream,
                initialData: MessageBloc().conversations,
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.hasError ||
                      snapshot.data.isEmpty) {
                    return Container();
                  }

                  conversations = snapshot.data;
                  if (selectedConversation == null) {
                    selectedConversation = conversations.first;
                  } else {
                    selectedConversation = conversations.firstWhere((c) {
                      return c.toId == selectedConversation.toId;
                    }, orElse: () => conversations.first);
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (conversations.length < 2) {
                      setState(() => showDrawer = false);
                    } else {
                      setState(() => showDrawer = true);
                    }
                  });

                  return ListView(
                    padding: EdgeInsets.zero,
                    reverse: true,
                    children: [
                      for (Message message in selectedConversation.messages)
                        Align(
                          alignment: message.fromMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            margin: EdgeInsets.only(
                              top: 12,
                              left: message.fromMe ? 72 : 24,
                              right: message.fromMe ? 24 : 72,
                            ),
                            decoration: BoxDecoration(
                                color: !message.fromMe
                                    ? Theme.of(context).cardColor
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Text(message.message),
                          ),
                        ),
                    ],
                  );
                }),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 36.0, top: 16.0),
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: 5,
                    minLines: 1,
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onEditingComplete: _sendMessage,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      hintText: 'Message',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      alignLabelWithHint: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                    ),
                    onChanged: (s) => newMessage = s,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 14.0),
                  padding: EdgeInsets.only(left: 3.0),
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Colors.blue,
                  ),
                  child: GestureDetector(
                    child: Icon(
                      LineAwesomeIcons.send_o,
                      size: 32.0,
                    ),
                    onTap: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _sendMessage() async {
    String message = newMessage;
    newMessage = "";
    FocusScope.of(context).unfocus();
    _controller.clear();
    MessageBloc().sendMessage(message, selectedConversation);
  }
}
