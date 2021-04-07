class Exercise {
  String title;
  String subtitle;
  String id;
  String description;
  String videoUrl;
  String imageUrl;
  int order;

  Exercise(title, subtitle, id, description, videoUrl, imageUrl, order) {
    this.title = title;
    this.subtitle = subtitle;
    this.videoUrl = videoUrl;
    this.description = description;
    this.id = id;
    this.imageUrl = imageUrl;
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      json['title'],
      json['subtitle'],
      json['id'],
      json['description'],
      json['videoUrl'],
      json['imageUrl'],
      json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['subtitle'] = this.subtitle;
    data['videoUrl'] = this.videoUrl;
    data['imageUrl'] = this.imageUrl;
    data['id'] = this.id;
    data['order'] = this.order;

    return data;
  }
}
