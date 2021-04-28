import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/exercise_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/exercise.dart';
import 'package:jdarwish_dashboard_web/shared/models/imagefileholder.dart';
import 'package:jdarwish_dashboard_web/shared/models/training_day.dart';
import 'package:jdarwish_dashboard_web/shared/utils/image_utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

class DaysPopup extends StatefulWidget {
  final TrainingDay trainingday;
  final int count;
  final PopUpFunctions popUpFunctions;
  final String id;
  DaysPopup(
      {this.trainingday,
      @required this.popUpFunctions,
      @required this.count,
      @required this.id});

  MyDaysPopup createState() => MyDaysPopup();
}

class MyDaysPopup extends State<DaysPopup> {
  String text = 'Only .png and .jpeg files allowed.';

  String title = "";
  String subtitle = "";
  bool isLoading = false;
  bool imageChanged = false;
  Image image;
  ImageFileHolder imageFileHolder;

  final titleController = TextEditingController();
  final subtitleController = TextEditingController();

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
      image = Image.network(widget.trainingday.imageUrl);

      titleController.text = widget.trainingday.title;

      subtitleController.text = widget.trainingday.subtitle;
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
            ? "Add Day"
            : "Edit Day",
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
                    labelText: 'subtitle',
                  ),
                  controller: subtitleController,
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
                          image = imageFileHolder.image;
                          imageChanged = true;
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
                isLoading = true;
                String imageURL = "";
                if (imageChanged) {
                  imageURL =
                      await uploadFileToCloudStorage(imageFileHolder.file);
                }

                switch (widget.popUpFunctions) {
                  case PopUpFunctions.add:
                    Navigator.pop(context);
                    _loadingDialog(context);
                    String id = Uuid().v1();
                    List<Exercise> exercises = [];
                    int order = widget.count != null ? widget.count : 0;
                    TrainingDay trainingday = TrainingDay(
                      title: title,
                      order: order,
                      subtitle: subtitle,
                      imageUrl: imageURL,
                      id: id,
                      exercises: exercises,
                    );
                    exerciseBloc.addTrainingDay(trainingday, widget.id);
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                    return;
                  case PopUpFunctions.edit:
                    Navigator.pop(context);
                    _loadingDialog(context);
                    widget.trainingday.subtitle = subtitle;
                    print(subtitle);

                    widget.trainingday.title = title;
                    print(title);
                    if (imageURL != "") {
                      widget.trainingday.imageUrl = imageURL;
                    }
                    print(imageURL);
                    exerciseBloc.editTrainingDay(widget.trainingday, widget.id);
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
    subtitleController.addListener(_updateLatestValue);
    titleController.addListener(_updateLatestValue);
    _setUpFunction();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();

    subtitleController.dispose();
  }

  _updateLatestValue() {
    title = titleController.text;

    subtitle = subtitleController.text;
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

class TransparentRoute4 extends PageRoute<void> {
  TransparentRoute4({
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
