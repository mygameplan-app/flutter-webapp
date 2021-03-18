import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:jdarwish_dashboard_web/shared/blocs/user_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/customer.dart';
import 'package:jdarwish_dashboard_web/shared/models/message.dart';
import 'package:rxdart/rxdart.dart';

import 'app_bloc.dart';
import '../constants.dart';

class MessageBloc {
  static final MessageBloc _singleton = MessageBloc._internal();
  factory MessageBloc() {
    return _singleton;
  }
  MessageBloc._internal();

  List<Message> messagesToMe = [];
  List<Message> messagesFromMe = [];
  List<Conversation> conversations;

  List<Customer> users;

  int unread;

  PublishSubject<List<Conversation>> _subject = PublishSubject();
  Stream<List<Conversation>> get conversationStream => _subject.stream;

  PublishSubject<int> _unreadSubject = PublishSubject();
  Stream<int> get unreadStream => _unreadSubject.stream;

  PublishSubject<List<Customer>> _customerSubject = PublishSubject();
  Stream<List<Customer>> get customerStream => _customerSubject.stream;

  Future<void> loadMessages() async {
    FirebaseFirestore.instance
        .collection("apps")
        .doc(appId)
        .collection("customers")
        .doc(AppBloc().adminId)
        .collection("conversations")
        .doc(UserBloc().fbUser.uid)
        .snapshots()
        .listen((snapshot) {
      final unread = snapshot.data()['unread'];
      if (unread != null) {
        this.unread = unread;
        _unreadSubject.add(unread);
      }
    });

    FirebaseFirestore.instance
        .collection("apps")
        .doc(appId)
        .collection("customers")
        .doc(UserBloc().fbUser.uid)
        .collection('messages')
        .snapshots()
        .listen((snapshot) {
      this.messagesFromMe = [];

      for (var m in snapshot.docs) {
        this
            .messagesFromMe
            .add(Message.fromJson(m.data())..setMe(UserBloc().fbUser.uid));
      }

      List<Message> messages = [...this.messagesFromMe, ...this.messagesToMe];
      messages.sort((a, b) => b.time.compareTo(a.time));

      conversations = [
        Conversation(
          toId: AppBloc().adminId,
          messages: messages,
        )
      ];

      _subject.add(conversations);
    });

    FirebaseFirestore.instance
        .collection("apps")
        .doc(appId)
        .collection("customers")
        .doc(AppBloc().adminId)
        .collection("conversations")
        .doc(UserBloc().fbUser.uid)
        .collection('messages')
        .snapshots()
        .listen((snapshot) {
      this.messagesToMe = [];

      for (var m in snapshot.docs) {
        this
            .messagesToMe
            .add(Message.fromJson(m.data())..setMe(UserBloc().fbUser.uid));
      }

      List<Message> messages = [...this.messagesFromMe, ...this.messagesToMe];
      messages.sort((a, b) => b.time.compareTo(a.time));

      conversations = [
        Conversation(
          toId: AppBloc().adminId,
          messages: messages,
        )
      ];

      _subject.add(conversations);
    });
  }

  Future<void> loadUsers() async {
    if (UserBloc().fbUser.uid != AppBloc().adminId) {
      return;
    }

    FirebaseFirestore.instance
        .collection("apps")
        .doc(appId)
        .collection("customers")
        .snapshots()
        .listen((snapshot) {
      users = [];

      for (var c in snapshot.docs) {
        if (c.id == UserBloc().fbUser.uid) {
          continue;
        }

        users.add(Customer.fromJson(c.data())..id = c.id);
      }
      users.sort((a, b) => b.unread.compareTo(a.unread));
      _customerSubject.add(users);
    });
  }

  Future<void> loadMessagesFromCustomer(String uid) async {
    FirebaseFirestore.instance
        .collection("apps")
        .doc(appId)
        .collection("customers")
        .doc(uid)
        .collection('messages')
        .snapshots()
        .listen((snapshot) {
      this.messagesToMe = [];

      for (var m in snapshot.docs) {
        this
            .messagesToMe
            .add(Message.fromJson(m.data())..setMe(UserBloc().fbUser.uid));
      }

      List<Message> messages = [...this.messagesFromMe, ...this.messagesToMe];
      print(messages.map((e) => e.message).toList().join(","));

      messages.sort((a, b) => b.time.compareTo(a.time));

      conversations = [
        Conversation(
          toId: uid,
          messages: messages,
        )
      ];

      _subject.add(conversations);
    });

    FirebaseFirestore.instance
        .collection("apps")
        .doc(appId)
        .collection("customers")
        .doc(AppBloc().adminId)
        .collection("conversations")
        .doc(uid)
        .collection('messages')
        .snapshots()
        .listen((snapshot) {
      this.messagesFromMe = [];

      for (var m in snapshot.docs) {
        this
            .messagesFromMe
            .add(Message.fromJson(m.data())..setMe(UserBloc().fbUser.uid));
      }

      List<Message> messages = [...this.messagesFromMe, ...this.messagesToMe];
      messages.sort((a, b) => b.time.compareTo(a.time));

      conversations = [
        Conversation(
          toId: uid,
          messages: messages,
        )
      ];

      _subject.add(conversations);
    });
  }

  Future<void> sendMessage(String message, Conversation conversation) async {
    bool userIsAdmin = UserBloc().fbUser.uid == AppBloc().adminId;
    if (userIsAdmin) {
      await FirebaseFirestore.instance
          .collection("apps")
          .doc(appId)
          .collection("customers")
          .doc(UserBloc().fbUser.uid)
          .collection("conversations")
          .doc(conversation.toId)
          .collection("messages")
          .add({
        "message": message,
        "fromId": UserBloc().fbUser.uid,
        "toId": conversation.toId,
        "time": DateTime.now(),
      });
      await FirebaseFirestore.instance
          .collection("apps")
          .doc(appId)
          .collection("customers")
          .doc(UserBloc().fbUser.uid)
          .collection("conversations")
          .doc(conversation.toId)
          .set({
        'unread': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } else {
      await FirebaseFirestore.instance
          .collection("apps")
          .doc(appId)
          .collection("customers")
          .doc(UserBloc().fbUser.uid)
          .collection("messages")
          .add({
        "message": message,
        "fromId": UserBloc().fbUser.uid,
        "toId": AppBloc().adminId,
        "time": DateTime.now(),
      });
      await FirebaseFirestore.instance
          .collection("apps")
          .doc(appId)
          .collection("customers")
          .doc(UserBloc().fbUser.uid)
          .set({
        'unread': FieldValue.increment(1),
      }, SetOptions(merge: true));
    }

    final token = (await FirebaseFirestore.instance
            .collection("apps")
            .doc(appId)
            .collection("customers")
            .doc(conversation.toId)
            .get())
        .data()["messagingToken"];

    // send notification
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAA0GQ4auI:APA91bEKE5bx5DwnhT-C854DJWXBpege7xubzFZk2cr_ziPWbLDxFOckNj9GtE6nkuCTC0wcP9TmDBEpYqlevz55qJlWbzri-TvM5YewUCsE2lox5LJ1CVwPtwx5vom9TIb0lJNI3Bv2',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': userIsAdmin
                ? 'New message from JDarwish'
                : 'New message from ${UserBloc().fbUser.displayName ?? UserBloc().fbUser.email}',
            'body': message,
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': token,
        },
      ),
    );
  }

  Future<void> markAllAsRead(Customer customer) async {
    if (customer != null) {
      await FirebaseFirestore.instance
          .collection("apps")
          .doc(appId)
          .collection('customers')
          .doc(customer.id)
          .set({'unread': 0}, SetOptions(merge: true));
    } else {
      await FirebaseFirestore.instance
          .collection("apps")
          .doc(appId)
          .collection('customers')
          .doc(AppBloc().adminId)
          .collection('conversations')
          .doc(UserBloc().fbUser.uid)
          .set({'unread': 0}, SetOptions(merge: true));
    }
  }
}
