import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/exercise_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/goal_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/lifestyle_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/message_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/nutrition_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/product_categories_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/user_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String email;
  String password;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Future<void> firebaseFuture;
  bool loading = false;
  bool newUser = false;
  @override
  void initState() {
    super.initState();
    firebaseFuture = initFirebase();
    firebaseFuture.then((_) {
      /* if (FirebaseAuth.instance.currentUser != null) {
        print('hi2');
        UserBloc().fbUser = FirebaseAuth.instance.currentUser;
        _continueToHome();
      } */
    });

    emailController.addListener(_updateLatestValue);
    passwordController.addListener(_updateLatestValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.

    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  _updateLatestValue() {
    email = emailController.text;
    password = passwordController.text;
  }

  Future<void> initFirebase() async {
    try {
      Firebase.app();
      await Firebase.initializeApp();
      await AppBloc().fetchAppData();
      if (FirebaseAuth.instance.currentUser != null) {
        UserBloc().fbUser = FirebaseAuth.instance.currentUser;

        _continueToHome();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: firebaseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Container(
                  color: Colors.black,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
                Image.network(
                  AppBloc().backgroundUrl,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.3),
                  colorBlendMode: BlendMode.darken,
                ),
                Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.network(AppBloc().logoUrl, height: 100),
                          Container(
                            width: 500,
                            child: Column(
                              children: [
                                TextField(
                                  decoration:
                                      InputDecoration(labelText: 'Email'),
                                  keyboardType: TextInputType.emailAddress,
                                  controller: emailController,
                                ),
                                TextField(
                                  decoration:
                                      InputDecoration(labelText: 'Password'),
                                  controller: passwordController,
                                  obscureText: true,
                                ),
                                Container(
                                  width: 300,
                                  child: LongButton(
                                    text: 'Log In With Email',
                                    onPressed: _logIn,
                                    color: Colors.red,
                                    textColor: Colors.white,
                                    icon: LineAwesomeIcons.envelope,
                                  ),
                                ),
                              ],
                            ),
                          )

                          // LongButton(
                          //   text: 'Log In With Facebook',
                          //   onPressed: _logInWithFacebook,
                          //   color: Colors.blue,
                          //   icon: LineAwesomeIcons.facebook_f,
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset('assets/logo.png', height: 96),
                              Container(
                                height: 120,
                                width: 120,
                                child: CircularProgressIndicator(),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ));
          }
        });
  }

  _logIn() async {
    if (this.password == null || this.email == null) {
      return;
    }
    setState(() => loading = true);
    try {
      final result = newUser
          ? await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: this.email.trim(),
              password: this.password.trim(),
            )
          : await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: this.email.trim(),
              password: this.password.trim(),
            );

      if (result.user != null) {
        UserBloc().fbUser = result.user;
        FirebaseAuth.instance.authStateChanges().listen((user) {
          if (user == null) {
            Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (context) => LoginView()),
                (route) => false);
          }
        });
        ExerciseBloc().exercisePrograms = [];
        NutritionBloc().nutritionPrograms = [];
        ProductCategoriesBloc().categories = [];
        _continueToHome();
      }
    } on FirebaseAuthException catch (e) {
      showPlatformDialog(
        context: context,
        builder: (context) {
          return PlatformAlertDialog(
            title: Text('Login Failed'),
            content: Text(e.message),
            actions: [
              PlatformDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() => loading = false);

      return PlatformAlertDialog(
        title: Text('Login Failed'),
        content: Text(e.message),
        actions: [
          PlatformDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }
  }

  _logInWithFacebook() async {
    try {
      UserBloc().loginWithFacebook().then((_) {
        _continueToHome();
      }, onError: (e) {
        showPlatformDialog(
            context: context,
            builder: (context) {
              return PlatformAlertDialog(
                title: Text('Login Failed'),
                content: Text("Unable to sign in."),
                actions: [
                  PlatformDialogAction(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            });
      });
    } catch (e) {
      showPlatformDialog(
        context: context,
        builder: (context) {
          return PlatformAlertDialog(
            title: Text('Login Failed'),
            content: Text("Something went wrong."),
          );
        },
      );
    }
  }

  _continueToHome() async {
    //loading = true;

    await UserBloc().saveUserData();

    await Future.wait([
      ExerciseBloc().fetchExerciseData(),
      NutritionBloc().fetchNutritionData(),
      LifestyleBloc().fetchLifestyleData(),
      ProductCategoriesBloc().fetchCategories(),
      UserBloc().loadUserInfo(),
      GoalBloc().fetchGoals(),
      if (UserBloc().fbUser.uid != AppBloc().adminId)
        MessageBloc().loadMessages(),
      if (UserBloc().fbUser.uid == AppBloc().adminId) MessageBloc().loadUsers(),
    ]);
    print('blocs');

    Get.offAllNamed('/home', predicate: (route) => false);
  }
}
