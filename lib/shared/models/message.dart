import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String fromId;
  String toId;
  DateTime time;
  String message;
  bool fromMe;

  Message({
    this.fromId,
    this.toId,
    this.time,
    this.message,
  });

  void setMe(String uid) {
    this.fromMe = (uid == this.fromId);
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      fromId: json["fromId"],
      toId: json["toId"],
      time: (json["time"] as Timestamp).toDate(),
      message: json["message"],
    );
  }
}

class Conversation {
  String toId;
  List<Message> messages;

  Conversation({this.toId, this.messages});
}
