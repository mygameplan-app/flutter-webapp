import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jdarwish_dashboard_web/shared/models/goal.dart';
import '../constants.dart';

class GoalBloc {
  static final GoalBloc _singleton = GoalBloc._internal();
  factory GoalBloc() {
    return _singleton;
  }
  GoalBloc._internal();

  List<Goal> goals;

  Future<void> fetchGoals() async {
    final goalItems = await FirebaseFirestore.instance
        .collection("apps")
        .doc(appId)
        .collection("goals")
        .get();

    this.goals =
        goalItems.docs.map((e) => Goal.fromJson(e.data())..id = e.id).toList();
  }
}
