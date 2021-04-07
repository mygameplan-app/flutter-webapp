import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/models/training_day.dart';

class Program {
  String name;
  Color themeColor;
  String id;
  List<TrainingDay> trainingDays;
  int order;

  Program({
    this.name,
    this.themeColor,
    this.id,
    this.trainingDays,
    this.order,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      name: json['name'],
      themeColor: _parseColor(json['color']),
      trainingDays: [],
      order: json['order'] ?? 999,
    );
  }

  static Color _parseColor(String color) {
    if (color == null) return Colors.blue;

    return Color(int.parse(color.substring(1), radix: 16));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['color'] = _setColor(this.themeColor);
    data['order'] = this.order;
    data['id'] = this.id;
    data['name'] = this.name;

    return data;
  }

  static String _setColor(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toString()}';
  }
}
