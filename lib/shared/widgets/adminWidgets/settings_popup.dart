import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/background_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/image_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/logo_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/product_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:get/get.dart';
import 'dart:ui';

class SettingsPopup extends StatefulWidget {
  MySettingsPopup createState() => MySettingsPopup();
}

class MySettingsPopup extends State<SettingsPopup> {
  var isLoading = false.obs;
  Image logoImage;
  Image backgroundImage;
  AppBloc appBloc = AppBloc();
  BackgroundBloc backgroundBloc = BackgroundBloc();
  LogoBloc logoBloc = LogoBloc();
  double multiplier() {
    if (MediaQuery.of(context).size.width >
        MediaQuery.of(context).size.height) {
      return 0.5;
    } else {
      return 0.8;
    }
  }

  _setUpFunction() {
    logoImage = Image.network(appBloc.logoUrl);

    backgroundImage = Image.network(appBloc.backgroundUrl);
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
        title: "General Settings",
        content: StatefulBuilder(builder: (context, setState) {
          return Container(
            width: MediaQuery.of(context).size.width * multiplier(),
            child: Column(
              children: <Widget>[
                Text(
                  'Any updates will be applied on the next load of the app.',
                  style: TextStyle(fontSize: 16),
                ),
                logoImage != null
                    ? Container(
                        padding: EdgeInsets.only(top: 15),
                        child: logoImage,
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
                        logoImage = await logoBloc.uploadImage();

                        setState(() {
                          logoImage = logoImage;
                        });
                      },
                      child: Text('Change Logo',
                          style: TextStyle(
                            color: Colors.white,
                          ))),
                ),
                backgroundImage != null
                    ? Container(
                        padding: EdgeInsets.only(top: 15),
                        child: backgroundImage,
                        width: 150,
                        height: 150,
                      )
                    : Container(),
                Container(
                  height: 40,
                  width: 200,
                  padding: EdgeInsets.only(top: 15),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: MaterialButton(
                      color: Colors.grey,
                      onPressed: () async {
                        backgroundImage = await backgroundBloc.uploadImage();

                        setState(() {
                          backgroundImage = backgroundImage;
                        });
                      },
                      child: Text('Change Background',
                          style: TextStyle(
                            color: Colors.white,
                          ))),
                ),
              ],
            ),
          );
        }),
        buttons: [
          DialogButton(
            color: Colors.red,
            onPressed: () async {
              if (logoImage != null && backgroundImage != null) {
                //print(logoBloc.file.name);
                Navigator.pop(context);
                _loadingDialog(context);

                String backgroundRef = await backgroundBloc.uploadToFirebase();
                String logoRef = await logoBloc.uploadToFirebase();

                await appBloc.setAppData(backgroundRef, logoRef);
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
              }
            },
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  /*  Future<void> handleSubmit(){
    Dialog
  } */
  @override
  void initState() {
    _setUpFunction();
    Future.delayed(
        Duration.zero, () => _onAlertWithCustomContextPassed(context));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
