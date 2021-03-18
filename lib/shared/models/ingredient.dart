class Ingredient {
  String title;
  int order;
  String id;
  String imageUrl;

  Ingredient(title, order, id, imageUrl) {
    this.title = title;
    this.order = order;
    this.id = id;
    this.imageUrl = imageUrl;
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      json['title'],
      json['order'],
      json['id'] != null ? json['id'] : '',
      json['imageUrl'],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['order'] = this.order;
    data['id'] = this.id;
    data['imageUrl'] = this.imageUrl;

    return data;
  }
}
