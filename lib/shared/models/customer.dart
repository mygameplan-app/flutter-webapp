class Customer {
  String name;
  String id;
  String email;
  String imageUrl;
  int unread;
  Customer({this.name, this.email, this.id, this.imageUrl, this.unread});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'],
      email: json['email'],
      imageUrl: json['imageUrl'],
      unread: json['unread'] ?? 0,
    );
  }
}
