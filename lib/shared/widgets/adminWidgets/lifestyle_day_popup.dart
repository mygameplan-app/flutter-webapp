import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/lifestyle_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/imagefileholder.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_day.dart';
import 'package:jdarwish_dashboard_web/shared/utils/ImageUpload.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

class LifestyleDaysPopup extends StatefulWidget {
  final LifestyleDay lifestyleday;
  final int count;
  final PopUpFunctions popUpFunctions;
  final String id;
  LifestyleDaysPopup(
      {this.lifestyleday,
      @required this.count,
      @required this.popUpFunctions,
      @required this.id});

  MyLifestyleDaysPopup createState() => MyLifestyleDaysPopup();
}

class MyLifestyleDaysPopup extends State<LifestyleDaysPopup> {
  String text = 'Only .png and .jpeg files allowed.';

  String title = "";
  String description = "";
  bool isLoading = false;
  Image image;
  ImageFileHolder imageFileHolder;
  bool imageChanged = false;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

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
      image = Image.network(widget.lifestyleday.imageUrl);
      titleController.text = widget.lifestyleday.title;

      descriptionController.text = widget.lifestyleday.subtitle;
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
            ? "Add Lifestyle Day"
            : "Edit Lifestyle Day",
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
                    labelText: 'Description',
                  ),
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
                        imageFileHolder =
                            await ImageUploader.uploadImageToDevice();
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
              Navigator.pop(context);
              _loadingDialog(context);
              if (image != null) {
                isLoading = true;
                String imageURL = "";
                if (imageChanged) {
                  imageURL = await ImageUploader.uploadFileToCloudStorage(
                      imageFileHolder.file);
                }

                switch (widget.popUpFunctions) {
                  case PopUpFunctions.add:
                    String id = Uuid().v1();
                    int order = widget.count != null ? widget.count : 0;
                    List<LifestyleItem> items = [];
                    LifestyleDay lifestyleday = LifestyleDay(
                      title: title,
                      order: order,
                      subtitle: description,
                      id: id,
                      imageUrl: imageURL,
                      items: items,
                    );
                    lifestyleBloc.addLifestyleDay(lifestyleday, widget.id);
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                    return;
                  case PopUpFunctions.edit:
                    widget.lifestyleday.subtitle = descriptionController.text;
                    widget.lifestyleday.title = titleController.text;
                    if (imageURL != "") {
                      widget.lifestyleday.imageUrl = imageURL;
                    }
                    lifestyleBloc.editLifestyleDay(
                        widget.lifestyleday, widget.id);
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
    descriptionController.addListener(_updateLatestValue);
    titleController.addListener(_updateLatestValue);
    _setUpFunction();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();

    descriptionController.dispose();
  }

  _updateLatestValue() {
    title = titleController.text;

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

class TransparentRoute7 extends PageRoute<void> {
  TransparentRoute7({
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
