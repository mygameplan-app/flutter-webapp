import 'package:jdarwish_dashboard_web/shared/models/lifestyle.dart';

class LifestyleDay {
  String title;
  int order;
  String subtitle;
  String id;
  String imageUrl;
  List<LifestyleItem> items;

  LifestyleDay({
    this.title,
    this.order,
    this.subtitle,
    this.id,
    this.imageUrl,
    this.items,
  });

  factory LifestyleDay.fromJson(Map<String, dynamic> json) {
    return LifestyleDay(
      title: json['title'],
      order: json['order'],
      subtitle: json['subtitle'],
      id: json['id'],
      imageUrl: json['imageUrl'] ?? '',
      items: [],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['order'] = this.order;
    data['subtitle'] = this.subtitle;
    data['imageUrl'] = this.imageUrl;
    data['id'] = this.id;
    return data;
  }
}
