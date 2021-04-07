import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/models/product.dart';

class ProductCategory {
  String name;
  int order;
  Color themeColor;
  String id;
  String timeStamp;
  List<Product> products = [];

  ProductCategory({
    this.name,
    this.order,
    this.themeColor,
    this.id,
    this.timeStamp,
    this.products,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      name: json['name'],
      order: json['order'] ?? 999,
      themeColor: _parseColor(json['themeColor']),
      id: json['id'],
      timeStamp: json['timeStamp'],
      products: [],
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
    data['timeStamp'] = this.timeStamp;
    return data;
  }

  static String _setColor(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toString()}';
  }
}
