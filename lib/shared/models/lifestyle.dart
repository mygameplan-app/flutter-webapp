class LifestyleItem {
  String title;
  String subtitle;
  String id;
  String imageUrl;
  String videoUrl;
  int order;

  LifestyleItem({
    this.title,
    this.subtitle,
    this.imageUrl,
    this.videoUrl,
    this.id,
    this.order,
  });

  factory LifestyleItem.fromJson(Map<String, dynamic> json) {
    return LifestyleItem(
      title: json['title'],
      subtitle: json['subtitle'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      order: json['order'] ?? 999,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['subtitle'] = this.subtitle;
    data['order'] = this.order;
    data['imageUrl'] = this.imageUrl;
    data['videoUrl'] = this.videoUrl;
    data['id'] = this.id;

    return data;
  }
}
