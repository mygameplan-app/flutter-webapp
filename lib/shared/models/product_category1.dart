import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/models/product.dart';

class ProductCategory {
  String name;
  int order;
  Color themeColor;
  String id;
  String timeStamp;
  List<Product> products = [];
  ProductCategory(name, order, themeColor, id, timeStamp, products) {
    this.name = name != null ? name : '';
    this.order = order != null ? order : 0;
    this.themeColor = themeColor != null ? themeColor : Colors.blue;
    this.id = id != null ? id : '';
    this.timeStamp = timeStamp != null ? timeStamp : '';
    this.products = products != null ? products : [];
  }
  ProductCategory.init2(
      {this.name,
      this.order,
      this.themeColor,
      this.id,
      this.timeStamp,
      this.products});
  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory.init2(
        name: json['name'] != null ? json['name'] : '',
        order: json['order'] != null ? json['order'] : 0,
        themeColor: json['themeColor'] != null
            ? _parseColor(json['themeColor'].toString())
            : Colors.blue,
        id: json['id'] != null ? json['id'] : '',
        timeStamp: json['timeStamp'] != null ? json['timeStamp'] : '',
        products: []);
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
    data['timeStamp'] = this.timeStamp;
    return data;
  }

  static String _setColor(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toString()}';
  }
}
