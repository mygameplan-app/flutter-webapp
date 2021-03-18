import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jdarwish_dashboard_web/shared/models/goal.dart';

class UserData {
  String stripeId;
  String stripeLink;
  List<ExerciseHistory> histories;
  List<GoalEntry> goalEntries;

  UserData({
    this.stripeId,
    this.stripeLink,
    this.histories,
    this.goalEntries,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      stripeId: json["stripeId"],
      stripeLink: json["stripeLink"],
      histories: [],
      goalEntries: [],
    );
  }
}

class ExerciseHistory {
  DateTime date;
  String exerciseId;
  List<ExerciseSet> sets;
}

class ExerciseSet {
  double weight;
  int reps;
  DateTime date;

  ExerciseSet({
    this.weight,
    this.reps,
    this.date,
  });

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      weight: json["weight"],
      reps: json["reps"],
      date: (json["date"] as Timestamp).toDate(),
    );
  }
}
