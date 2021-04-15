import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_day.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_program.dart';

import '../constants.dart';

class LifestyleBloc {
  static final LifestyleBloc _singleton = LifestyleBloc._internal();

  factory LifestyleBloc() {
    return _singleton;
  }

  LifestyleBloc._internal();
  List<LifestyleProgram> lifestylePrograms = [];

  Future<void> fetchLifestyleData() async {
    lifestylePrograms = [];
    List<Future> futures = [];
    final programDocs = await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('lifestyle')
        .get();

    for (var p in programDocs.docs) {
      if (lifestylePrograms.where((prog) => prog.id == p.id).isNotEmpty) {
        // we already did this. yikes race conditions
        return;
      }
      LifestyleProgram program = LifestyleProgram.fromJson(p.data())..id = p.id;
      lifestylePrograms.add(program);
      final dayFuture = p.reference
          .collection('days')
          .orderBy('order')
          .get()
          .then((dayDocs) async {
        for (var d in dayDocs.docs) {
          LifestyleDay day = LifestyleDay.fromJson(d.data())..id = d.id;
          program.lifestyleDays.add(day);
          await d.reference
              .collection('items')
              .orderBy('order')
              .get()
              .then((lifestyleDocs) async {
            for (var e in lifestyleDocs.docs) {
              LifestyleItem item = LifestyleItem.fromJson(e.data())..id = e.id;
              day.items.add(item);
            }
          });
        }
      });
      futures.add(dayFuture);
    }

    Future.wait(futures);
  }

  void addLifestyleItem(
      String programId, String dayId, LifestyleItem item) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('lifestyle')
        .doc(programId)
        .collection('days')
        .doc("defaultDay")
        .set({"order": 0}, options);

    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('lifestyle')
        .doc(programId)
        .collection('days')
        .doc("defaultDay")
        .collection('items')
        .doc(item.id)
        .set(item.toJson(), options);
  }

  void editLifestyleItem(
      String programId, String dayId, LifestyleItem item) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('lifestyle')
        .doc(programId)
        .collection('days')
        .doc("defaultDay")
        .collection('items')
        .doc(item.id)
        .set(item.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void addLifestyleDay(LifestyleDay lifestyleDay, String id) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('lifestyle')
        .doc(id)
        .collection('days')
        .doc(lifestyleDay.id)
        .set(lifestyleDay.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void editLifestyleDay(LifestyleDay lifestyleDay, String id) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('lifestyle')
        .doc(id)
        .collection('days')
        .doc(lifestyleDay.id)
        .set(lifestyleDay.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void addLifestyleProgram(LifestyleProgram lifestyleProgram) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('lifestyle')
        .doc(lifestyleProgram.id)
        .set(lifestyleProgram.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void editLifestyleProgram(LifestyleProgram lifestyleProgram) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('lifestyle')
        .doc(lifestyleProgram.id)
        .set(lifestyleProgram.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }
}
