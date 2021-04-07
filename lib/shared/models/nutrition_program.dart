import 'package:flutter/material.dart';

import 'nutrition_day.dart';

class NutritionProgram {
  String name;
  int order;
  Color themeColor;
  String id;
  List<NutritionDay> nutritionDays;

  NutritionProgram({
    this.name,
    this.order,
    this.themeColor,
    this.id,
    this.nutritionDays,
  });

  factory NutritionProgram.fromJson(Map<String, dynamic> json) {
    return NutritionProgram(
      name: json['name'] != null ? json['name'] : '',
      order: json['order'] != null ? json['order'] : 0,
      themeColor: json['themeColor'] != null
          ? _parseColor(json['themeColor'].toString())
          : Colors.blue,
      id: json['id'] != null ? json['id'] : '',
      nutritionDays: [],
    );
  }

  static Color _parseColor(String color) {
    if (color == null) return Colors.blue;
    final buffer = StringBuffer();
    if (color.length == 6 || color.length == 7) buffer.write('ff');
    buffer.write(color.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['order'] = this.order;
    data['themeColor'] = _setColor(this.themeColor);
    data['id'] = this.id;
    return data;
  }

  static String _setColor(Color color) {
    print(color.toString());
    return '#${color.value.toRadixString(16).substring(2).toString()}';
  }
}
