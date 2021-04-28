import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/exercise_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/exercise.dart';
import 'package:jdarwish_dashboard_web/shared/models/imagefileholder.dart';
import 'package:jdarwish_dashboard_web/shared/models/program.dart';
import 'package:jdarwish_dashboard_web/shared/models/training_day.dart';
import 'package:jdarwish_dashboard_web/shared/utils/image_utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

class ExercisePopup extends StatefulWidget {
  final TrainingDay trainingday;
  final Program program;
  final int count;
  final PopUpFunctions popUpFunctions;
  final Exercise exercise;

  ExercisePopup({
    @required this.trainingday,
    this.exercise,
    @required this.count,
    @required this.program,
    @required this.popUpFunctions,
  });

  MyExercisePopup createState() => MyExercisePopup();
}

class MyExercisePopup extends State<ExercisePopup> {
  String text = 'Only .png and .jpeg files allowed.';
  String description = "";
  String title = "";
  String videoUrl1 = "";
  bool isLoading = false;
  bool imageChanged = false;
  Image image;
  ImageFileHolder imageFileHolder;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final videoUrlController = TextEditingController();

  ExerciseBloc exerciseBloc = ExerciseBloc();

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
      image = Image.network(widget.exercise.imageUrl);

      titleController.text = widget.exercise.title;
      descriptionController.text = widget.exercise.description;
      videoUrlController.text = widget.exercise.videoUrl;
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
            ? "Add Exercise"
            : "Edit Exercise",
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
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  controller: descriptionController,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Youtube Video URL',
                  ),
                  controller: videoUrlController,
                ),
                image != null
                    ? Container(
                        padding: EdgeInsets.only(top: 15),
                        child: image,
                        width: 150,
                        height: 150,
                      )
                    : Container(
                        child:
                            Icon(Icons.image, color: Colors.white, size: 50)),
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
                String refURL = "";
                if (imageChanged) {
                  refURL = await uploadFileToCloudStorage(
                      imageFileHolder.file);
                }

                switch (widget.popUpFunctions) {
                  case PopUpFunctions.add:
                    String id = Uuid().v1();
                    String subtitle = "";
                    int order = widget.count != null ? widget.count : 0;
                    Exercise exercise = Exercise(
                      title,
                      subtitle,
                      id,
                      description,
                      videoUrl1,
                      refURL,
                      order,
                    );
                    exerciseBloc.addExercise(
                        widget.trainingday, widget.program, exercise);
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                    return;
                  case PopUpFunctions.edit:
                    widget.exercise.videoUrl = videoUrl1;
                    widget.exercise.title = titleController.text;
                    widget.exercise.description = descriptionController.text;
                    if (refURL != "") {
                      widget.exercise.imageUrl = refURL;
                    }
                    exerciseBloc.editExercise(
                        widget.trainingday, widget.program, widget.exercise);
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                    return;
                }
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
    Future.delayed(
        Duration.zero, () => _onAlertWithCustomContextPassed(context));
    titleController.addListener(_updateLatestValue);
    descriptionController.addListener(_updateLatestValue);
    videoUrlController.addListener(_updateLatestValue);
    _setUpFunction();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    videoUrlController.dispose();
  }

  _updateLatestValue() {
    title = titleController.text;
    description = descriptionController.text;
    videoUrl1 = videoUrlController.text;
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

class TransparentRoute5 extends PageRoute<void> {
  TransparentRoute5({
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
