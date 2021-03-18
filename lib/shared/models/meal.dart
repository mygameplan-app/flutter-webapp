import 'package:jdarwish_dashboard_web/shared/models/ingredient.dart';

class Meal {
  String title;
  int order;
  String subtitle;
  String description;
  String id;
  String imageUrl;
  List<Ingredient> ingredients;
  Meal(title, order, subtitle, description, id, imageUrl, ingredients) {
    this.title = title != null ? title : '';
    this.order = order != null ? order : '';
    this.subtitle = subtitle != null ? subtitle : '';
    this.description = description != null ? description : '';
    this.id = id != null ? id : '';
    this.imageUrl = imageUrl != null ? imageUrl : '';
    this.ingredients = ingredients != null ? ingredients : [];
  }
  Meal.init2(
      {this.title,
      this.order,
      this.subtitle,
      this.description,
      this.id,
      this.imageUrl,
      this.ingredients});
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal.init2(
        title: json['title'] != null ? json['title'] : '',
        order: json['order'] != null ? json['order'] : 0,
        subtitle: json['subtitle'] != null ? json['subtitle'] : '',
        description: json['description'] != null ? json['description'] : '',
        id: json['id'] != null ? json['id'] : '',
        imageUrl: json['imageUrl'] != null ? json['imageUrl'] : '',
        ingredients: []);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['order'] = this.order;
    data['subtitle'] = this.subtitle;
    data['description'] = this.description;
    data['id'] = this.id;
    data['imageUrl'] = this.imageUrl;
    return data;
  }
}
