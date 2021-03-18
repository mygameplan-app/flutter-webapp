import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jdarwish_dashboard_web/shared/models/ingredient.dart';
import 'package:jdarwish_dashboard_web/shared/models/meal.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_day.dart';

import 'package:jdarwish_dashboard_web/shared/models/nutrition_program.dart';

import '../constants.dart';

class NutritionBloc {
  static final NutritionBloc _singleton = NutritionBloc._internal();
  factory NutritionBloc() {
    return _singleton;
  }
  NutritionBloc._internal();

  List<NutritionProgram> nutritionPrograms = [];

  Future<void> fetchNutritionData() async {
    nutritionPrograms = [];
    List<Future> futures = [];
    final programDocs = await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('nutritionPrograms')
        .get();

    for (var p in programDocs.docs) {
      NutritionProgram program = NutritionProgram.fromJson(p.data())..id = p.id;
      nutritionPrograms.add(program);
      final dayFuture = p.reference
          .collection('days')
          .orderBy('order')
          .get()
          .then((dayDocs) async {
        for (var d in dayDocs.docs) {
          NutritionDay day = NutritionDay.fromJson(d.data())..id = d.id;
          program.nutritionDays.add(day);
          await d.reference
              .collection('meals')
              .orderBy('order')
              .get()
              .then((nutritionDocs) async {
            for (var e in nutritionDocs.docs) {
              Meal meal = Meal.fromJson(e.data())..id = e.id;
              day.meals.add(meal);
              await e.reference
                  .collection('ingredients')
                  .get()
                  .then((ingredientDocs) {
                for (var i in ingredientDocs.docs) {
                  Ingredient ingredient = Ingredient.fromJson(i.data())
                    ..id = i.id;
                  meal.ingredients.add(ingredient);
                }
              });
            }
          });
        }
      });
      futures.add(dayFuture);
    }

    Future.wait(futures);
  }

  void addNutritionProgram(NutritionProgram nutritionProgram) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('nutritionPrograms')
        .doc(nutritionProgram.id)
        .set(nutritionProgram.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void editNutritionProgram(NutritionProgram nutritionProgram) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('nutritionPrograms')
        .doc(nutritionProgram.id)
        .set(nutritionProgram.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void addNutritionDay(NutritionDay nutritionDay, String id) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('nutritionPrograms')
        .doc(id)
        .collection('days')
        .doc(nutritionDay.id)
        .set(nutritionDay.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void editNutritionDay(NutritionDay nutritionDay, String id) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('nutritionPrograms')
        .doc(id)
        .collection('days')
        .doc(nutritionDay.id)
        .set(nutritionDay.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void addMeal(NutritionDay nutritionDay, NutritionProgram nutritionprogram,
      Meal meal) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('nutritionPrograms')
        .doc(nutritionprogram.id)
        .collection('days')
        .doc(nutritionDay.id)
        .collection('meals')
        .doc(meal.id)
        .set(meal.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void editMeal(NutritionDay nutritionDay, NutritionProgram nutritionprogram,
      Meal meal) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('nutritionPrograms')
        .doc(nutritionprogram.id)
        .collection('days')
        .doc(nutritionDay.id)
        .collection('meals')
        .doc(meal.id)
        .set(meal.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void addIngredient(
      NutritionDay nutritionDay,
      NutritionProgram nutritionprogram,
      Meal meal,
      Ingredient ingredient) async {
    final options = SetOptions(merge: true);

    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('nutritionPrograms')
        .doc(nutritionprogram.id)
        .collection('days')
        .doc(nutritionDay.id)
        .collection('meals')
        .doc(meal.id)
        .collection('ingredients')
        .doc(ingredient.id)
        .set(ingredient.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }

  void editIngredient(
      NutritionDay nutritionDay,
      NutritionProgram nutritionprogram,
      Meal meal,
      Ingredient ingredient) async {
    final options = SetOptions(merge: true);
    await FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('nutritionPrograms')
        .doc(nutritionprogram.id)
        .collection('days')
        .doc(nutritionDay.id)
        .collection('meals')
        .doc(meal.id)
        .collection('ingredients')
        .doc(ingredient.id)
        .set(ingredient.toJson(), options)
        .then((value) => print('uploaded successfully'));
  }
}
