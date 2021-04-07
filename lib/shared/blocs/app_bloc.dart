import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';

class AppBloc {
  static final AppBloc _singleton = AppBloc._internal();

  factory AppBloc() {
    return _singleton;
  }

  AppBloc._internal();

  String logoUrl;
  String backgroundUrl;
  String adminId;
  String adminName;

  Future<void> fetchAppData() async {
    final appData =
        await FirebaseFirestore.instance.collection("apps").doc(appId).get();

    this.logoUrl = appData.data()["logoUrl"];
    this.backgroundUrl = appData.data()["backgroundUrl"];
    this.adminId = appData.data()["admin"];
    this.adminName = appData.data()["adminName"];
  }

  Future<void> setAppData(String backgroundUrl, String logoUrl) async {
    Map<String, dynamic> json = {};
    if (backgroundUrl?.isNotEmpty ?? false) {
      json["backgroundUrl"] = backgroundUrl;
    }
    if (logoUrl?.isNotEmpty ?? false) {
      json["logoUrl"] = logoUrl;
    }

    await FirebaseFirestore.instance
        .collection("apps")
        .doc(appId)
        .set(json, SetOptions(merge: true));
  }
}
