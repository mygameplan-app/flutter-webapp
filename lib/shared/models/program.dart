import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/models/training_day.dart';

class Program {
  String name;
  int order;
  Color themeColor;
  String id;
  List<TrainingDay> trainingDays;
  Program(name, order, themeColor, id, trainingDays) {
    this.name = name != null ? name : '';
    this.order = order != null ? order : 0;
    this.themeColor = themeColor != null ? themeColor : Colors.blue;
    this.id = id != null ? id : '';
    this.trainingDays = trainingDays != null ? trainingDays : [];
  }
  Program.init2({
    this.name,
    this.order,
    this.themeColor,
    this.id,
    this.trainingDays,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program.init2(
      name: json['name'] != null ? json['name'] : '',
      order: json['order'] != null ? json['order'] : 0,
      themeColor:
          json['color'] != null ? _parseColor(json['color']) : Colors.blue,
      id: json['id'] != null ? json['id'].toString() : '',
      trainingDays: [],
    );
  }
  //Fix color mapping
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['color'] = _setColor(this.themeColor);
    data['order'] = this.order;
    data['id'] = this.id;
    data['name'] = this.name;

    return data;
  }

  static Color _parseColor(String color) {
    if (color == null) return Colors.blue;
    final buffer = StringBuffer();
    if (color.length == 6 || color.length == 7) buffer.write('ff');
    buffer.write(color.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String _setColor(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toString()}';
  }
}
