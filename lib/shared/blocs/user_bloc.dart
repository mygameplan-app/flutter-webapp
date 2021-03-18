import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:jdarwish_dashboard_web/shared/models/exercise.dart';
import 'package:jdarwish_dashboard_web/shared/models/goal.dart';
import 'package:jdarwish_dashboard_web/shared/models/user_data.dart';

import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import '../constants.dart';

class UserBloc {
  static final UserBloc _singleton = UserBloc._internal();
  factory UserBloc() {
    return _singleton;
  }
  UserBloc._internal();

  User fbUser;
  UserData userData;

  Future<void> loginWithFacebook() async {
    try {
      final facebookLogin = FacebookLogin();
      final result = await facebookLogin.logIn(['email']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final cred =
              FacebookAuthProvider.credential(result.accessToken.token);
          final firebaseResult =
              await FirebaseAuth.instance.signInWithCredential(cred);
          if (firebaseResult.user != null) {
            this.fbUser = firebaseResult.user;
          }
          break;
        case FacebookLoginStatus.cancelledByUser:
          return;
          break;
        case FacebookLoginStatus.error:
          throw result.errorMessage;
          break;
      }
    } catch (e) {
      throw e;
    }
  }

  // check if a user has paid
  Future<bool> checkEmail(String email) async {
    final potentialUsers = await FirebaseFirestore.instance
        .collection("apps")
        .doc(appId)
        .collection("customers")
        .where("email", isEqualTo: email)
        .get();

    return potentialUsers.docs.isNotEmpty;
  }

  // check if a user has created an account
  Future<bool> checkUser(String email) async {
    final potentialUsers =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

    return potentialUsers.isNotEmpty;
  }

  Future<void> loadUserInfo() async {
    final user = await FirebaseFirestore.instance
        .collection("apps")
        .doc(appId)
        .collection("customers")
        .doc(fbUser.uid)
        .get();

    UserData userData = UserData.fromJson(user.data() ?? {});
    final historyDocs =
        await user.reference.collection("exerciseHistories").get();

    for (var h in historyDocs.docs) {
      final setDocs = await h.reference.collection("sets").get();

      List<ExerciseSet> allSets = [];
      for (var s in setDocs.docs) {
        allSets.add(ExerciseSet.fromJson(s.data()));
      }
      for (ExerciseSet set in allSets) {
        bool added = false;
        for (ExerciseHistory history in userData.histories) {
          if (history.date.difference(set.date).abs() < Duration(hours: 2)) {
            history.sets.add(set);
            added = true;
            break;
          }
        }
        if (!added) {
          ExerciseHistory history = ExerciseHistory();
          history.date = set.date;
          history.exerciseId = h.id;
          history.sets = [set];
          userData.histories.add(history);
        }
      }
    }

    final goalDocs = await user.reference.collection("goals").get();

    for (var g in goalDocs.docs) {
      final entryDocs = await g.reference.collection("entries").get();

      List<GoalEntry> entries = [];
      for (var e in entryDocs.docs) {
        entries.add(GoalEntry.fromJson(e.data())
          ..id = e.id
          ..goalId = g.id);
      }

      userData.goalEntries.addAll(entries);
    }

    this.userData = userData;
  }

  Future<void> addSet(Exercise exercise, int reps, double weight) async {
    final doc = await FirebaseFirestore.instance
        .collection("apps")
        .doc(appId)
        .collection("customers")
        .doc(fbUser.uid)
        .collection("exerciseHistories")
        .doc(exercise.id)
        .get();

    if (!doc.exists) {
      doc.reference.set({});
    }

    await doc.reference.collection("sets").add({
      "reps": reps,
      "weight": weight,
      "date": DateTime.now(),
    });

    await this.loadUserInfo();
  }

  Future<void> addGoalEntry(Goal goal, int value, DateTime date) async {
    if (this.userData.goalEntries.where((e) {
      return e.date.day == date.day &&
          e.date.month == date.month &&
          e.date.year == date.year;
    }).isNotEmpty) {
      throw "Entry already exists for this date";
    }

    final doc = await FirebaseFirestore.instance
        .collection("apps")
        .doc(appId)
        .collection("customers")
        .doc(fbUser.uid)
        .collection("goals")
        .doc(goal.id)
        .get();

    if (!doc.exists) {
      doc.reference.set({});
    }

    await doc.reference.collection("entries").add({
      "value": value,
      "date": date ?? DateTime.now(),
    });

    await this.loadUserInfo();
  }

  Future<void> saveMessagingToken(String token) async {
    print('error?');
    await FirebaseFirestore.instance
        .collection("apps")
        .doc(appId)
        .collection("customers")
        .doc(fbUser.uid)
        .set(
      {"messagingToken": token},
      SetOptions(merge: true),
    );
  }

  Future<void> saveUserData() async {
    await FirebaseFirestore.instance
        .collection("customers")
        .doc(fbUser.uid)
        .set(
      {
        "name": fbUser.displayName,
        "email": fbUser.email,
        "imageUrl": fbUser.photoURL,
      },
      SetOptions(merge: true),
    );
  }

  bool get isAdmin => fbUser.uid == AppBloc().adminId;
}
