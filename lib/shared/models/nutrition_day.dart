import 'meal.dart';

class NutritionDay {
  String title;
  int order;
  String subtitle;
  String id;
  String imageUrl;
  List<Meal> meals;

  NutritionDay({
    this.title,
    this.order,
    this.subtitle,
    this.id,
    this.imageUrl,
    this.meals,
  });

  factory NutritionDay.fromJson(Map<String, dynamic> json) {
    return NutritionDay(
      title: json['title'],
      order: json['order'],
      subtitle: json['subtitle'],
      id: json['id'],
      imageUrl: json['imageUrl'] ?? '',
      meals: [],
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
