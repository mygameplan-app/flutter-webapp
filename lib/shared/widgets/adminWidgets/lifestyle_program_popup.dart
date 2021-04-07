import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/lifestyle_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_day.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_program.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

class LifestyleCategoryPopup extends StatefulWidget {
  final LifestyleProgram lifestyleProgram;
  final PopUpFunctions popUpFunctions;
  final int count;
  LifestyleCategoryPopup(
      {this.lifestyleProgram,
      @required this.count,
      @required this.popUpFunctions});

  MyLifestyleCategoryPopup createState() => MyLifestyleCategoryPopup();
}

class MyLifestyleCategoryPopup extends State<LifestyleCategoryPopup> {
  String name = "";
  Color selectedColor;
  final nameController = TextEditingController();
  LifestyleBloc lifestyleBloc = LifestyleBloc();

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
      nameController.text = widget.lifestyleProgram.name;
      setState(() {
        print(widget.lifestyleProgram.themeColor);
        selectedColor = widget.lifestyleProgram.themeColor;
      });
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
    print(selectedColor);
    setColor() {
      setState(() {});
    }

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
            ? "Add Lifestyle Category"
            : "Edit Lifestyle Category",
        content: StatefulBuilder(builder: (context, setState) {
          return Container(
            width: MediaQuery.of(context).size.width * multiplier(),
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                  controller: nameController,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Theme Color:'),
                      ),
                      MaterialButton(
                        child: CircleAvatar(
                          backgroundColor: selectedColor,
                        ),
                        onPressed: () {
                          showDialog(
                              context: (context),
                              builder: (_) {
                                return AlertDialog(
                                  title: Text(
                                    'Choose Color:',
                                    style: TextStyle(
                                        color: Colors.grey[50], fontSize: 14),
                                  ),
                                  content: MaterialColorPicker(
                                      onColorChange: (Color color) {
                                        // Handle color changes
                                        setState(() {
                                          print('hi');
                                          selectedColor = color;
                                        });
                                        setColor();
                                      },
                                      onMainColorChange: (ColorSwatch color) {
                                        // Handle main color changes
                                        print(color);
                                      },
                                      selectedColor: selectedColor),
                                  actions: [
                                    MaterialButton(
                                      child: Text('Save'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
        buttons: [
          DialogButton(
            color: Colors.red,
            onPressed: () async {
              Navigator.pop(context);
              _loadingDialog(context);
              switch (widget.popUpFunctions) {
                case PopUpFunctions.add:
                  String id = Uuid().v1();
                  List<LifestyleDay> days = [];
                  Color themeColor = selectedColor;
                  int order = widget.count != null ? widget.count : 0;
                  LifestyleProgram lifestyleProgram = LifestyleProgram(
                    name: name,
                    order: order,
                    themeColor: themeColor,
                    id: id,
                    lifestyleDays: days,
                  );
                  lifestyleBloc.addLifestyleProgram(lifestyleProgram);
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 2);
                  return;
                case PopUpFunctions.edit:
                  widget.lifestyleProgram.name = name;
                  widget.lifestyleProgram.themeColor = selectedColor;
                  lifestyleBloc.editLifestyleProgram(widget.lifestyleProgram);
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 2);
                  return;
              }
            },
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  @override
  void initState() {
    nameController.addListener(_updateLatestValue);
    _setUpFunction();
    Future.delayed(
        Duration.zero, () => _onAlertWithCustomContextPassed(context));

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  _updateLatestValue() {
    name = nameController.text;
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

class TransparentRoute6 extends PageRoute<void> {
  TransparentRoute6({
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
