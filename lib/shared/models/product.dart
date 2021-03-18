class Product {
  String title;
  int order;
  String description;
  String price;
  String link;
  String storedImageURL;
  String id;
  String timeStamp;
  Product(
      title, order, description, price, link, storedImageURL, id, timeStamp) {
    this.title = title != null ? title : '';
    this.order = order != null ? order : 0;
    this.description = description != null ? description : '';
    this.price = price != null ? price : '';
    this.link = link != null ? link : '';
    this.storedImageURL = storedImageURL != null ? storedImageURL : '';
    this.id = id != null ? id : '';
    this.timeStamp = timeStamp != null ? timeStamp : '';
  }
  Product.init2({
    this.title,
    this.order,
    this.description,
    this.price,
    this.link,
    this.storedImageURL,
    this.id,
    this.timeStamp,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product.init2(
      title: json['title'] != null ? json['title'] : '',
      order: json['order'] != null ? json['order'] : 0,
      description: json['description'] != null ? json['description'] : '',
      price: json['price'] != null ? json['price'] : '',
      link: json['link'] != null ? json['link'] : '',
      storedImageURL:
          json['storedImageURL'] != null ? json['storedImageURL'] : '',
      id: json['id'] != null ? json['id'] : '',
      timeStamp: json['timeStamp'] != null ? json['timeStamp'] : '',
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['order'] = this.order;
    data['description'] = this.description;
    data['price'] = this.price;
    data['link'] = this.link;
    data['storedImageURL'] = this.storedImageURL;
    data['id'] = this.id;
    data['timeStamp'] = this.timeStamp;
    return data;
  }
}
