import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/days_pics_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/exercise_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/image_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/meal_pics_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/nutrition_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/nutrition_day_picsbloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/product_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/ingredient.dart';
import 'package:jdarwish_dashboard_web/shared/models/meal.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_day.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_program.dart';

import 'package:uuid/uuid.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'dart:ui';

class MealsPopup extends StatefulWidget {
  final NutritionDay nutritionday;
  final int count;
  final PopUpFunctions popUpFunctions;
  final NutritionProgram nutritionProgram;
  final Meal meal;
  MealsPopup(
      {this.nutritionday,
      @required this.count,
      @required this.popUpFunctions,
      @required this.nutritionProgram,
      this.meal});

  MyMealsPopup createState() => MyMealsPopup();
}

class MyMealsPopup extends State<MealsPopup> {
  String text = 'Only .png and .jpeg files allowed.';

  String title = "";
  String description = "";
  String subtitle = "";
  bool isLoading = false;
  bool imageChanged = false;
  Image image;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final subtitleController = TextEditingController();
  NutritionBloc nutritionBloc = NutritionBloc();

  MealPicsBloc mealsPicsBloc = MealPicsBloc();
  double multiplier() {
    if (MediaQuery.of(context).size.width >
        MediaQuery.of(context).size.height) {
      return 0.5;
    } else {
      return 0.8;
    }
  }

  _setUpFunction() {
    if (widget.popUpFunctions == PopUpFunctions.Edit) {
      image = Image.network(widget.meal.imageUrl);

      titleController.text = widget.meal.title;
      subtitleController.text = widget.meal.subtitle;
      descriptionController.text = widget.meal.description;
    }
  }

  _loadingDialog(context) {
    showDialog(
        barrierDismissible: false,
        context: (context),
        builder: (
          BuildContext context,
        ) {
          return AlertDialog(
            backgroundColor: Colors.black26,
            content: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                      Text(
                        'Loading...',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  _onAlertWithCustomContextPassed(context) {
    Alert(
        closeFunction: () {
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 2);
        },
        style: AlertStyle(
            backgroundColor: Colors.black,
            titleStyle: TextStyle(color: Colors.white, fontSize: 20)),
        context: context,
        title: widget.popUpFunctions == PopUpFunctions.Add
            ? "Add Meal"
            : "Edit Meal",
        content: StatefulBuilder(builder: (context, setState) {
          return Container(
            width: MediaQuery.of(context).size.width * multiplier(),
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                  controller: titleController,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Subtitle',
                  ),
                  controller: subtitleController,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 15,
                  controller: descriptionController,
                ),
                image != null
                    ? Container(
                        padding: EdgeInsets.only(top: 15),
                        child: image,
                        width: 150,
                        height: 150,
                      )
                    : Container(),
                Container(
                  height: 40,
                  width: 140,
                  padding: EdgeInsets.only(top: 15),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: MaterialButton(
                      color: Colors.grey,
                      onPressed: () async {
                        image = await mealsPicsBloc.uploadImage();
                        setState(() {
                          imageChanged = true;
                          image = image;
                        });
                      },
                      child: Text('Choose Image',
                          style: TextStyle(
                            color: Colors.white,
                          ))),
                ),
                Text(text,
                    style: TextStyle(
                      fontSize: 14,
                    ))
              ],
            ),
          );
        }),
        buttons: [
          DialogButton(
            color: Colors.red,
            onPressed: () async {
              if (image != null) {
                Navigator.pop(context);
                _loadingDialog(context);
                String imageURL = "";
                if (imageChanged) {
                  imageURL = await mealsPicsBloc.uploadToFirebase();
                }

                if (imageURL != "") {
                  switch (widget.popUpFunctions) {
                    case PopUpFunctions.Add:
                      String id = Uuid().v1();
                      List<Ingredient> ingredients = [];
                      int order = widget.count != null ? widget.count : 0;
                      Meal meal = Meal(title, order, subtitle, description, id,
                          imageURL, ingredients);
                      nutritionBloc.addMeal(
                          widget.nutritionday, widget.nutritionProgram, meal);
                      int count = 0;
                      Navigator.of(context).popUntil((_) => count++ >= 2);
                      return;
                    case PopUpFunctions.Edit:
                      widget.meal.subtitle = subtitleController.text;
                      widget.meal.title = titleController.text;
                      widget.meal.description = descriptionController.text;
                      widget.meal.imageUrl = imageURL;
                      nutritionBloc.editMeal(widget.nutritionday,
                          widget.nutritionProgram, widget.meal);
                      int count = 0;
                      Navigator.of(context).popUntil((_) => count++ >= 2);
                      return;
                  }
                }
              }
            },
            child: isLoading
                ? CircularProgressIndicator(backgroundColor: Colors.white)
                : Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
          )
        ]).show();
  }

  @override
  void initState() {
    Future.delayed(
        Duration.zero, () => _onAlertWithCustomContextPassed(context));
    descriptionController.addListener(_updateLatestValue);
    titleController.addListener(_updateLatestValue);
    subtitleController.addListener(_updateLatestValue);
    _setUpFunction();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    subtitleController.dispose();
    descriptionController.dispose();
  }

  _updateLatestValue() {
    title = titleController.text;
    subtitle = subtitleController.text;
    description = descriptionController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 5.0,
              sigmaY: 5.0), //this is dependent on the import statment above
          child: Container(
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2)))),
    ]);
  }
}

class TransparentRoute8 extends PageRoute<void> {
  TransparentRoute8({
    @required this.builder,
    RouteSettings settings,
  })  : assert(builder != null),
        super(settings: settings, fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 350);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final result = builder(context);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: result,
      ),
    );
  }
}
