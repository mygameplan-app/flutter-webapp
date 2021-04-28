import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/nutrition_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/imagefileholder.dart';
import 'package:jdarwish_dashboard_web/shared/models/ingredient.dart';
import 'package:jdarwish_dashboard_web/shared/models/meal.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_day.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_program.dart';
import 'package:jdarwish_dashboard_web/shared/utils/image_utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

class IngredientsPopup extends StatefulWidget {
  final NutritionDay nutritionday;
  final PopUpFunctions popUpFunctions;
  final int count;
  final NutritionProgram nutritionProgram;
  final Meal meal;
  final Ingredient ingredient;
  IngredientsPopup({
    this.nutritionday,
    @required this.count,
    @required this.popUpFunctions,
    @required this.nutritionProgram,
    @required this.meal,
    this.ingredient,
  });

  MyIngredientsPopup createState() => MyIngredientsPopup();
}

class MyIngredientsPopup extends State<IngredientsPopup> {
  String text = 'Only .png and .jpeg files allowed.';

  String title = "";

  bool isLoading = false;

  Image image;
  ImageFileHolder imageFileHolder;
  bool imageChanged = false;
  final titleController = TextEditingController();

  NutritionBloc nutritionBloc = NutritionBloc();

  double multiplier() {
    if (MediaQuery.of(context).size.width >
        MediaQuery.of(context).size.height) {
      return 0.5;
    } else {
      return 0.8;
    }
  }

  _setUpFunction() {
    if (widget.popUpFunctions == PopUpFunctions.edit) {
      image = Image.network(widget.ingredient.imageUrl);

      titleController.text = widget.ingredient.title;
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
        title: widget.popUpFunctions == PopUpFunctions.add
            ? "Add Ingredient"
            : "Edit Ingredient",
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
                        imageFileHolder = await uploadImageToDevice();
                        setState(() {
                          imageChanged = true;
                          image = imageFileHolder.image;
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
                  imageURL =
                      await uploadFileToCloudStorage(imageFileHolder.file);
                }

                switch (widget.popUpFunctions) {
                  case PopUpFunctions.add:
                    String id = Uuid().v1();
                    int order = widget.count != null ? widget.count : 0;
                    print(imageURL);
                    Ingredient ingredient = Ingredient(
                      title,
                      order,
                      id,
                      imageURL,
                    );
                    nutritionBloc.addIngredient(widget.nutritionday,
                        widget.nutritionProgram, widget.meal, ingredient);
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                    return;
                  case PopUpFunctions.edit:
                    widget.ingredient.title = titleController.text;
                    if (imageURL != "") {
                      widget.ingredient.imageUrl = imageURL;
                    }
                    nutritionBloc.editIngredient(
                        widget.nutritionday,
                        widget.nutritionProgram,
                        widget.meal,
                        widget.ingredient);

                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                    return;
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

    titleController.addListener(_updateLatestValue);

    _setUpFunction();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  _updateLatestValue() {
    title = titleController.text;
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

class TransparentRoute10 extends PageRoute<void> {
  TransparentRoute10({
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
