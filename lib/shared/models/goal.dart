import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Goal {
  String title;
  String id;
  Color color;

  Goal({
    this.title,
    this.id,
    this.color,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(title: json['title'], color: _parseColor(json['color']));
  }

  static Color _parseColor(String color) {
    if (color == null) return Colors.blue;

    return Color(int.parse(color.substring(1), radix: 16));
  }
}

class GoalEntry {
  String id;
  String goalId;
  int value;
  DateTime date;

  GoalEntry({
    this.value,
    this.date,
  });

  factory GoalEntry.fromJson(Map<String, dynamic> json) {
    return GoalEntry(
      value: json["value"],
      date: (json["date"] as Timestamp).toDate(),
    );
  }
}
