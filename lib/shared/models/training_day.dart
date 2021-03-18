import 'package:jdarwish_dashboard_web/shared/models/exercise.dart';

class TrainingDay {
  String title;
  int order;
  String subtitle;
  String id;
  String imageUrl;
  List<Exercise> exercises;
  TrainingDay(title, order, subtitle, imageUrl, id, exercises) {
    this.title = title != null ? title : '';
    this.order = order != null ? order : 0;
    this.subtitle = subtitle != null ? subtitle : '';
    this.imageUrl = imageUrl != null ? imageUrl : '';
    this.id = id != null ? id : '';
    this.exercises = exercises != null ? exercises : [];
  }
  TrainingDay.init2({
    this.title,
    this.order,
    this.subtitle,
    this.imageUrl,
    this.id,
    this.exercises,
  });

  factory TrainingDay.fromJson(Map<String, dynamic> json) {
    return TrainingDay.init2(
      title: json['title'] != null ? json['title'] : '',
      order: json['order'] != null ? json['order'] : 0,
      subtitle: json['subtitle'] != null ? json['subtitle'] : '',
      imageUrl: json['imageUrl'] != null ? json['imageUrl'] : '',
      id: json['id'] != null ? json['id'] : '',
      exercises: [],
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
