import 'meal.dart';

class NutritionDay {
  String title;
  int order;
  String subtitle;
  String id;
  String imageUrl;
  List<Meal> meals;
  NutritionDay(title, order, subtitle, id, imageUrl, meals) {
    this.title = title != null ? title : '';
    this.order = order != null ? order : 0;
    this.subtitle = subtitle != null ? subtitle : '';
    this.id = id != null ? id : '';
    this.imageUrl = imageUrl != null ? imageUrl : '';

    this.meals = meals != null ? meals : [];
  }
  NutritionDay.init2({
    this.title,
    this.order,
    this.subtitle,
    this.id,
    this.imageUrl,
    this.meals,
  });

  factory NutritionDay.fromJson(Map<String, dynamic> json) {
    return NutritionDay.init2(
      title: json['title'],
      order: json['order'],
      subtitle: json['subtitle'],
      id: json['id'] != null ? json['id'] : '',
      imageUrl: json['imageUrl'] != null ? json['imageUrl'] : '',
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
