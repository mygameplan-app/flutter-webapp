import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/exercise_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/image_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/product_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/program.dart';
import 'package:jdarwish_dashboard_web/shared/models/training_day.dart';

import 'package:uuid/uuid.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'dart:ui';

class ProgramPopup extends StatefulWidget {
  final Program program;
  final PopUpFunctions popUpFunctions;
  final int count;
  ProgramPopup(
      {this.program, @required this.popUpFunctions, @required this.count});

  MyProgramPopup createState() => MyProgramPopup();
}

class MyProgramPopup extends State<ProgramPopup> {
  String name = "";
  final nameController = TextEditingController();
  ExerciseBloc exerciseBloc = ExerciseBloc();
  Color selectedColor;
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
      nameController.text = widget.program.name;
      setState(() {
        selectedColor = widget.program.themeColor;
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
            ? "Add Workout"
            : "Edit Workout",
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
                      FlatButton(
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
                                          selectedColor = color;
                                        });
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
                case PopUpFunctions.Add:
                  String id = Uuid().v1();

                  Color themeColor = selectedColor;
                  int order = widget.count != null ? widget.count : 0;
                  List<TrainingDay> days = [];
                  Program program = Program(name, order, themeColor, id, days);
                  exerciseBloc.addProgram(program);
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 2);
                  return;
                case PopUpFunctions.Edit:
                  widget.program.name = name;
                  widget.program.themeColor = selectedColor;
                  exerciseBloc.editProgram(widget.program);
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

class TransparentRoute2 extends PageRoute<void> {
  TransparentRoute2({
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
