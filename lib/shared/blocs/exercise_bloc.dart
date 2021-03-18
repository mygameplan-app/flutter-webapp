import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jdarwish_dashboard_web/shared/models/exercise.dart';
import 'package:jdarwish_dashboard_web/shared/models/program.dart';

import 'package:jdarwish_dashboard_web/shared/models/training_day.dart';

import '../constants.dart';

class ExerciseBloc {
  static final ExerciseBloc _singleton = ExerciseBloc._internal();
  factory ExerciseBloc() {
    return _singleton;
  }
  ExerciseBloc._internal();

  List<Program> exercisePrograms = [];

  Future<void> fetchExerciseData() async {
    List<Future> futures = [];
    exercisePrograms.clear();
    exercisePrograms = [];
    final programDocs = await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('exercisePrograms')
        .get();
    print(programDocs.docs.length);
    for (var p in programDocs.docs) {
      Program program = Program.fromJson(p.data())..id = p.id;
      exercisePrograms.add(program);
      final dayFuture = p.reference.collection('days').get().then((dayDocs) {
        for (var d in dayDocs.docs) {
          TrainingDay day = TrainingDay.fromJson(d.data())..id = d.id;
          program.trainingDays.add(day);
          d.reference.collection('exercises').get().then((exerciseDocs) {
            for (var e in exerciseDocs.docs) {
              Exercise exercise = Exercise.fromJson(e.data())..id = e.id;
              day.exercises.add(exercise);
            }
          });
        }
      });
      futures.add(dayFuture);
    }
    Future.wait(futures);
  }

  void addProgram(Program program) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('exercisePrograms')
        .doc(program.id)
        .set(program.toJson(), options);
  }

  void editProgram(Program program) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('exercisePrograms')
        .doc(program.id)
        .set(program.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void addTrainingDay(TrainingDay trainingDay, String id) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('exercisePrograms')
        .doc(id)
        .collection('days')
        .doc(trainingDay.id)
        .set(trainingDay.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void editTrainingDay(TrainingDay trainingDay, String id) async {
    final options = SetOptions(merge: true);

    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('exercisePrograms')
        .doc(id)
        .collection('days')
        .doc(trainingDay.id)
        .set(trainingDay.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void addExercise(
      TrainingDay trainingDay, Program program, Exercise exercise) async {
    final options = SetOptions(merge: true);

    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('exercisePrograms')
        .doc(program.id)
        .collection('days')
        .doc(trainingDay.id)
        .collection('exercises')
        .doc(exercise.id)
        .set(exercise.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void editExercise(
      TrainingDay trainingDay, Program program, Exercise exercise) async {
    final options = SetOptions(merge: true);

    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('exercisePrograms')
        .doc(program.id)
        .collection('days')
        .doc(trainingDay.id)
        .collection('exercises')
        .doc(exercise.id)
        .set(exercise.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }
}
