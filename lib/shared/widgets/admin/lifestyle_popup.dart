import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/lifestyle_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/imagefileholder.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_day.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_program.dart';
import 'package:jdarwish_dashboard_web/shared/utils/image_utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

class LifestylePopup extends StatefulWidget {
  final LifestyleProgram lifestyleProgram;
  final LifestyleDay lifestyleDay;
  final LifestyleItem item;
  final int count;
  final PopUpFunctions popUpFunctions;

  LifestylePopup({
    this.item,
    @required this.lifestyleProgram,
    @required this.lifestyleDay,
    @required this.count,
    @required this.popUpFunctions,
  });

  _LifestylePopupState createState() => _LifestylePopupState();
}

class _LifestylePopupState extends State<LifestylePopup> {
  String text = 'Only .png and .jpeg files allowed.';
  String videoUrl = "";
  String title = "";
  String subtitle = "";
  bool isLoading = false;
  bool imageChanged = false;
  Image image;
  ImageFileHolder imageFileHolder;

  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final videoUrlController = TextEditingController();

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
      image = widget.item.imageUrl == null
          ? null
          : Image.network(widget.item.imageUrl);
      titleController.text = widget.item.title;
      subtitleController.text = widget.item.subtitle;
      videoUrlController.text = widget.item.videoUrl;
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
            ? "Add Lifestyle Item"
            : "Edit Lifestyle Item",
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
                    labelText: 'Subtitle',
                  ),
                  controller: subtitleController,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Video URL',
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
                    LifestyleItem lifestyleItem2 = LifestyleItem(
                      title: title,
                      order: order,
                      subtitle: subtitle,
                      videoUrl: videoUrl,
                      imageUrl: imageURL,
                      id: id,
                    );
                    LifestyleBloc().addLifestyleItem(widget.lifestyleProgram.id,
                        widget.lifestyleDay.id, lifestyleItem2);
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                    return;
                  case PopUpFunctions.edit:
                    widget.item.subtitle = subtitleController.text;
                    widget.item.title = titleController.text;
                    widget.item.videoUrl = videoUrlController.text;
                    if (imageURL != "") {
                      widget.item.imageUrl = imageURL;
                    }
                    LifestyleBloc().editLifestyleItem(
                        widget.lifestyleProgram.id,
                        widget.lifestyleDay.id,
                        widget.item);
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
    videoUrlController.addListener(_updateLatestValue);
    titleController.addListener(_updateLatestValue);
    subtitleController.addListener(_updateLatestValue);
    Future.delayed(
      Duration.zero,
      () => _onAlertWithCustomContextPassed(context),
    );
    _setUpFunction();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    subtitleController.dispose();
    videoUrlController.dispose();
  }

  _updateLatestValue() {
    title = titleController.text;
    subtitle = subtitleController.text;
    videoUrl = videoUrlController.text;
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

class TransparentRoute extends PageRoute<void> {
  TransparentRoute({
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
