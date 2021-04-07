import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle.dart';

import '../constants.dart';

class LifestyleBloc {
  static final LifestyleBloc _singleton = LifestyleBloc._internal();

  factory LifestyleBloc() {
    return _singleton;
  }

  LifestyleBloc._internal();

  List<LifestyleItem> lifestyleItems = [];

  Future<void> fetchLifestyleData() async {
    lifestyleItems = [];

    final programDocs = await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('lifestyle')
        .get();

    for (var p in programDocs.docs) {
      LifestyleItem item = LifestyleItem.fromJson(p.data())..id = p.id;
      lifestyleItems.add(item);
    }
  }

  void addLifestyleItem(LifestyleItem item) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('lifestyle')
        .doc(item.id)
        .set(item.toJson(), options);
  }

  void editLifestyleItem(LifestyleItem item) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('lifestyle')
        .doc(item.id)
        .set(item.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }
}
