import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/nutrition_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/constants.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/ingredient.dart';
import 'package:jdarwish_dashboard_web/shared/models/meal.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_day.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_program.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/admin/exercise_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/admin/ingredients_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/admin/product_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/admin/reorderableFirebaseList.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:uuid/uuid.dart';

class IngredientsAdmin extends StatefulWidget {
  final NutritionProgram nutritionProgram;
  final NutritionDay nutritionDay;

  final Meal meal;

  IngredientsAdmin({
    @required this.nutritionProgram,
    @required this.nutritionDay,
    @required this.meal,
  });

  MyIngredientsAdmin createState() => MyIngredientsAdmin();
}

class MyIngredientsAdmin extends State<IngredientsAdmin> {
  //Variables
  List<Ingredient> ingredients = [];
  bool isReordering = false;

  //ListView
  Column loadListView(QuerySnapshot querySnapshot, String id) {
    ingredients = querySnapshot.docs
        .map<Ingredient>((ingredient) =>
            Ingredient.fromJson(ingredient.data())..id = ingredient.id)
        .toList();

    List<Widget> containers = [];
    containers.add(Center(
      child: Container(
        height: 100,
        width: 240,
        child: LongButton(
          text: 'Add Ingredient',
          icon: Icons.add,
          color: Colors.red,
          textColor: Colors.white,
          onPressed: () {
            IngredientsPopup ingredientsPopup = IngredientsPopup(
                popUpFunctions: PopUpFunctions.add,
                count: ingredients.length,
                nutritionProgram: widget.nutritionProgram,
                nutritionday: widget.nutritionDay,
                meal: widget.meal);
            Navigator.push(context,
                TransparentRoute(builder: (context) => ingredientsPopup));
          },
        ),
      ),
    ));
    int counter = 0;
    for (Ingredient ingredient in ingredients) {
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
            padding: EdgeInsets.only(top: 10),
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
                        doPopUp(result, ingredient);
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
                    ingredient.imageUrl,
                    height: 60,
                    width: 80,
                    fit: BoxFit.cover,
                  )
                ],
              ),
            ),
          ),
          title: Text(ingredient.title,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ));
      counter += 1;
    }
    return Column(children: containers);
  }

  void doPopUp(Functions result, Ingredient ingredient) async {
    switch (result) {
      case Functions.delete:
        await FirebaseFirestore.instance
            .collection('apps')
            .doc(appId)
            .collection('nutritionPrograms')
            .doc(widget.nutritionProgram.id)
            .collection('days')
            .doc(widget.nutritionDay.id)
            .collection('meals')
            .doc(widget.meal.id)
            .collection('ingredients')
            .doc(ingredient.id)
            .delete();

        return;
      case Functions.edit:
        IngredientsPopup ingredientsPopup = IngredientsPopup(
          popUpFunctions: PopUpFunctions.edit,
          count: ingredients.length,
          ingredient: ingredient,
          meal: widget.meal,
          nutritionday: widget.nutritionDay,
          nutritionProgram: widget.nutritionProgram,
        );
        await Navigator.push(
            context, TransparentRoute5(builder: (context) => ingredientsPopup));

        return;
      case Functions.duplicate:
        Ingredient newIngredient = ingredient;
        newIngredient.id = Uuid().v1();
        newIngredient.order = ingredients != null ? ingredients.length : 0;

        NutritionBloc().addIngredient(widget.nutritionDay,
            widget.nutritionProgram, widget.meal, newIngredient);
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
  StreamBuilder ingredientsFetcher() {
    Query ingredientsQuery = FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('nutritionPrograms')
        .doc(widget.nutritionProgram.id)
        .collection('days')
        .doc(widget.nutritionDay.id)
        .collection('meals')
        .doc(widget.meal.id)
        .collection('ingredients')
        .orderBy('order');

    return StreamBuilder<QuerySnapshot>(
      stream: ingredientsQuery.snapshots(),
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
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  LineAwesomeIcons.cutlery,
                  color: Colors.white,
                  size: 38,
                ),
                SizedBox(height: 20),
                Container(
                  width: 240.0,
                  child: Text(
                    "No Ingredients added.",
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 100,
                  width: 240,
                  child: LongButton(
                    text: 'Add Ingredient',
                    icon: Icons.add,
                    color: Colors.red,
                    textColor: Colors.white,
                    onPressed: () async {
                      IngredientsPopup ingredientsPopup = IngredientsPopup(
                        popUpFunctions: PopUpFunctions.add,
                        count: ingredients.length,
                        nutritionProgram: widget.nutritionProgram,
                        meal: widget.meal,
                        nutritionday: widget.nutritionDay,
                      );
                      await Navigator.push(
                          context,
                          TransparentRoute(
                              builder: (context) => ingredientsPopup));
                    },
                  ),
                ),
              ],
            );
          } else {
            return Container(
                width: 500, child: loadListView(querySnapshot, widget.meal.id));
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
    ListTile getlistTile(Ingredient ingredient, int index) {
      return ListTile(
        key: Key(index.toString()),
        contentPadding: EdgeInsets.only(top: 10, bottom: 10),
        leading: Image.network(
          ingredient.imageUrl,
          height: 60,
          width: 80,
          fit: BoxFit.cover,
        ),
        title: Text(ingredient.title),
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
            .doc(widget.nutritionDay.id)
            .collection('meals')
            .doc(widget.meal.id)
            .collection('ingredients'),
        indexKey: 'order',
        itemBuilder: (BuildContext context, int index, DocumentSnapshot doc) {
          return getlistTile(
              Ingredient.fromJson(doc.data())..id = doc.id, index);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.nutritionProgram.name}/ ${widget.nutritionDay.title}/ ${widget.meal.title}'),
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
                  padding: EdgeInsets.only(top: 10),
                  child: ListView(
                    children: [div1(), ingredientsFetcher()],
                  ),
                ),
              )
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
