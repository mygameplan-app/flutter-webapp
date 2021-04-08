import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/nutrition_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/constants.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/meal.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_day.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_program.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/exercise_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/meals_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/product_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/reorderableFirebaseList.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:uuid/uuid.dart';

class MealAdmin extends StatefulWidget {
  final NutritionProgram nutritionProgram;
  final NutritionDay nutritionDay;

  MealAdmin({@required this.nutritionProgram, @required this.nutritionDay});

  MyMealAdmin createState() => MyMealAdmin();
}

class MyMealAdmin extends State<MealAdmin> {
  //Variables
  List<Meal> meals = [];
  bool isReordering = false;

  //ListView
  Widget loadListView(QuerySnapshot querySnapshot, String id) {
    meals = querySnapshot.docs
        .map<Meal>((meal) => Meal.fromJson(meal.data()))
        .toList();

    List<Widget> containers = [];
    containers.add(Center(
      child: Container(
        height: 100,
        width: 240,
        child: LongButton(
          text: 'Add Meal',
          icon: Icons.add,
          color: Colors.red,
          textColor: Colors.white,
          onPressed: () {
            MealsPopup mealsPopup = MealsPopup(
              popUpFunctions: PopUpFunctions.add,
              count: meals.length,
              nutritionProgram: widget.nutritionProgram,
              nutritionday: widget.nutritionDay,
            );
            Navigator.push(
                context, TransparentRoute(builder: (context) => mealsPopup));
          },
        ),
      ),
    ));
    int counter = 0;
    for (Meal meal in meals) {
      containers.add(Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white10,
            border: Border(
                top: counter == 0
                    ? BorderSide(color: Colors.grey, width: 1)
                    : BorderSide(color: Colors.transparent, width: 0),
                bottom: BorderSide(color: Colors.grey, width: 1))),
        child: ListTile(
          leading: Padding(
            padding: EdgeInsets.only(top: 0),
            child: SizedBox(
              width: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 20,
                      ),
                      onSelected: (Functions result) {
                        doPopUp(result, meal);
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<Functions>>[
                        const PopupMenuItem<Functions>(
                          value: Functions.edit,
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<Functions>(
                          value: Functions.duplicate,
                          child: Text('Duplicate'),
                        ),
                        const PopupMenuItem<Functions>(
                          value: Functions.delete,
                          child: Text('Delete'),
                        ),
                        const PopupMenuItem<Functions>(
                            value: Functions.reorder, child: Text('Reorder'))
                      ],
                    ),
                  ),
                  Image.network(
                    meal.imageUrl,
                    height: 60,
                    width: 80,
                    fit: BoxFit.cover,
                  )
                ],
              ),
            ),
          ),
          title: Text(meal.title,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          subtitle: Text(meal.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.normal)),
          trailing: Icon(
            Icons.navigate_next,
            size: 25,
            color: Colors.grey,
          ),
          // onTap: () {
          //   Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => IngredientsAdmin(
          //               nutritionDay: widget.nutritionDay,
          //               meal: meal,
          //               nutritionProgram: widget.nutritionProgram)));
          // },
        ),
      ));
      counter += 1;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(children: containers),
    );
  }

  void doPopUp(Functions result, Meal meal) async {
    switch (result) {
      case Functions.delete:
        await FirebaseFirestore.instance
            .collection('apps')
            .doc(appId)
            .collection('nutritionPrograms')
            .doc(widget.nutritionProgram.id)
            .collection('days')
            .doc("defaultDay")
            .collection('meals')
            .doc(meal.id)
            .delete();

        return;
      case Functions.edit:
        MealsPopup mealsPopup = MealsPopup(
          popUpFunctions: PopUpFunctions.edit,
          count: meals.length,
          meal: meal,
          nutritionday: widget.nutritionDay,
          nutritionProgram: widget.nutritionProgram,
        );
        await Navigator.push(
            context, TransparentRoute5(builder: (context) => mealsPopup));

        return;
      case Functions.duplicate:
        Meal newMeal = meal;
        newMeal.id = Uuid().v1();
        newMeal.order = meals != null ? meals.length : 0;
        NutritionBloc()
            .addMeal(widget.nutritionDay, widget.nutritionProgram, newMeal);
        return;
      case Functions.reorder:
        setState(() {
          isReordering = true;
        });
        return;
      default:
        return;
    }
  }

  //Product Stream
  StreamBuilder mealsFetcher() {
    Query mealQuery = FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('nutritionPrograms')
        .doc(widget.nutritionProgram.id)
        .collection('days')
        .doc("defaultDay")
        .collection('meals')
        .orderBy('order');
    return StreamBuilder<QuerySnapshot>(
      stream: mealQuery.snapshots(),
      builder: (context, stream) {
        if (stream.hasData == false) {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)));
        } else if (stream.hasError) {
          return Center(child: Text(stream.error.toString()));
        } else if (stream.hasData == true) {
          QuerySnapshot querySnapshot = stream.data;
          print(querySnapshot.docs.length);
          if (querySnapshot.docs.length == 0) {
            return Padding(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    LineAwesomeIcons.cutlery,
                    color: Colors.white,
                    size: 38,
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 240.0,
                    child: Text(
                      "No Meals added.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    height: 80,
                    width: 240,
                    child: LongButton(
                      text: 'Add Meal',
                      icon: Icons.add,
                      color: Colors.red,
                      textColor: Colors.white,
                      onPressed: () async {
                        MealsPopup mealsPopup = MealsPopup(
                          popUpFunctions: PopUpFunctions.add,
                          count: meals.length,
                          nutritionProgram: widget.nutritionProgram,
                          nutritionday: widget.nutritionDay,
                        );
                        await Navigator.push(context,
                            TransparentRoute(builder: (context) => mealsPopup));
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
                width: 500,
                child: loadListView(querySnapshot, widget.nutritionProgram.id));
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)));
        }
      },
    );
  }

  Widget reorderable() {
    ListTile getlistTile(Meal meal, int index) {
      return ListTile(
        contentPadding: EdgeInsets.only(top: 10, bottom: 10),
        key: Key(index.toString()),
        leading: Image.network(
          meal.imageUrl,
          height: 60,
          width: 80,
          fit: BoxFit.cover,
        ),
        title: Text(meal.title),
        trailing: Icon(
          Icons.reorder,
          size: 30,
          color: Colors.white,
        ),
      );
    }

    return ReorderableFirebaseList(
        collection: FirebaseFirestore.instance
            .collection('apps')
            .doc(appId)
            .collection('nutritionPrograms')
            .doc(widget.nutritionProgram.id)
            .collection('days')
            .doc("defaultDay")
            .collection('meals'),
        indexKey: 'order',
        itemBuilder: (BuildContext context, int index, DocumentSnapshot doc) {
          return getlistTile(Meal.fromJson(doc.data()), index);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nutritionProgram.name ?? ''),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          isReordering
              ? TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    setState(() {
                      isReordering = false;
                    });
                  },
                )
              : Container()
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        Image.network(
          AppBloc().backgroundUrl,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.3),
          colorBlendMode: BlendMode.darken,
        ),
        isReordering
            ? SafeArea(child: reorderable())
            : SafeArea(
                child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ListView(
                  children: [div1(), mealsFetcher()],
                ),
              ))
      ]),
    );
  }

  Widget div1() {
    return Divider(
      color: Colors.grey,
      height: 1,
      thickness: 1,
    );
  }
}
