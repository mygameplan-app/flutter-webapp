import 'package:jdarwish_dashboard_web/shared/models/ingredient.dart';

class Meal {
  String title;
  int order;
  String subtitle;
  String description;
  String id;
  String imageUrl;
  String videoUrl;
  List<Ingredient> ingredients;

  Meal({
    this.title,
    this.order,
    this.subtitle,
    this.description,
    this.id,
    this.imageUrl,
    this.videoUrl,
    this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      title: json['title'],
      order: json['order'] ?? 999,
      subtitle: json['subtitle'],
      description: json['description'],
      id: json['id'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      ingredients: [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['order'] = this.order;
    data['subtitle'] = this.subtitle;
    data['description'] = this.description;
    data['id'] = this.id;
    data['imageUrl'] = this.imageUrl;
    data['videoUrl'] = this.videoUrl;
    return data;
  }
}
