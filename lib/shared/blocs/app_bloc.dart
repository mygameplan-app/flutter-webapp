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

  Future<void> fetchAppData() async {
    final appData =
        await FirebaseFirestore.instance.collection("apps").doc(appId).get();

    this.logoUrl = appData.data()["logoUrl"];
    this.backgroundUrl = appData.data()["backgroundUrl"];
    this.adminId = appData.data()["admin"];
  }

  Future<String> getAdminEmail() async {
    final appData =
        await FirebaseFirestore.instance.collection("apps").doc(appId).get();
    String adminEmail = appData.data()["adminEmail"];
    return adminEmail;
  }

  Future<void> setAppData(String backgroundUrl1, String logoUrl1) async {
    final options = SetOptions(merge: true);
    if (logoUrl1 != "" && backgroundUrl != "") {
      Map<String, dynamic> json = {
        "logoUrl": logoUrl1,
        "backgroundUrl": backgroundUrl1
      };
      await FirebaseFirestore.instance
          .collection("apps")
          .doc(appId)
          .set(json, options);
    } else if (logoUrl1 == "" && backgroundUrl1 != "") {
      Map<String, dynamic> json = {"backgroundUrl": backgroundUrl1};
      await FirebaseFirestore.instance
          .collection("apps")
          .doc(appId)
          .set(json, options);
    } else if (logoUrl1 != "" && backgroundUrl1 == "") {
      Map<String, dynamic> json = {
        "logoUrl": logoUrl1,
      };
      await FirebaseFirestore.instance
          .collection("apps")
          .doc(appId)
          .set(json, options);
    }
  }
}
