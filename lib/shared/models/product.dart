class Product {
  String title;
  int order;
  String description;
  String price;
  String link;
  String imageUrl;
  String id;
  String timeStamp;

  Product({
    this.title,
    this.order,
    this.description,
    this.price,
    this.link,
    this.imageUrl,
    this.id,
    this.timeStamp,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['title'],
      order: json['order'],
      description: json['description'],
      price: json['price'],
      link: json['link'],
      imageUrl: json['storedImageURL'],
      id: json['id'],
      timeStamp: json['timeStamp'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['order'] = this.order;
    data['description'] = this.description;
    data['price'] = this.price;
    data['link'] = this.link;
    data['storedImageURL'] = this.imageUrl;
    data['id'] = this.id;
    data['timeStamp'] = this.timeStamp;
    return data;
  }
}
