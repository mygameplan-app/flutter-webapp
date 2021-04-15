import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String email;
  String password;

  bool emailEntered = false;
  bool newUser = false;
  bool loading = false;

  Future<void> firebaseFuture;

  Future<void> loadingFuture;

  @override
  void initState() {
    firebaseFuture = initFirebase();
    firebaseFuture.then((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        UserBloc().fbUser = FirebaseAuth.instance.currentUser;
        _continueToHome();
      }
    });

    super.initState();
  }

  Future<void> initFirebase() async {
    try {
      Firebase.app();
    } catch (e) {
      await Firebase.initializeApp();
      // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    }
    await AppBloc().fetchAppData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: firebaseFuture,
        builder: (context, snapshot) {
          bool loaded = snapshot.connectionState == ConnectionState.done;

          return Stack(
            children: [
              if (loaded)
                Image.network(
                  AppBloc().backgroundUrl,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.3),
                  colorBlendMode: BlendMode.darken,
                  // placeholder: (_, __) => Container(
                  //   height: MediaQuery.of(context).size.height,
                  //   width: MediaQuery.of(context).size.width,
                  //   color: Theme.of(context).canvasColor,
                  // ),
                ),
              Scaffold(
                backgroundColor: Colors.transparent,
                body: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (loaded) Image.network(AppBloc().logoUrl, width: 64),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: emailEntered
                              ? _passwordTextField()
                              : _emailTextField(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: loading || !loaded
                    ? Column(
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
                      )
                    : Container(),
              ),
            ],
          );
        });
  }

  _passwordTextField() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(children: [
        TextField(
          decoration: InputDecoration(
            labelText: newUser
                ? 'Create a password for this account'
                : 'Enter your password',
          ),
          onChanged: (password) => setState(() => this.password = password),
          obscureText: true,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlatButton(
              onPressed: () => setState(() => emailEntered = false),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0, right: 4.0),
                    child: Icon(
                      Icons.arrow_back,
                      size: 16.0,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    'Back',
                    style: TextStyle(color: Colors.blue, fontSize: 16.0),
                  ),
                ],
              ),
            ),
            FlatButton(
              onPressed: () => _logIn(),
              child: Row(
                children: [
                  Text(
                    newUser ? 'Create Account' : 'Sign In',
                    style: TextStyle(color: Colors.blue, fontSize: 16.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0, left: 4.0),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 16.0,
                      color: Colors.blue,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }

  _emailTextField() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        key: ValueKey('email'),
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Enter your email'),
            keyboardType: TextInputType.emailAddress,
            onChanged: (email) => setState(() => this.email = email?.trim()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlatButton(
                onPressed: () => _checkEmail(),
                child: Row(
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(color: Colors.blue, fontSize: 16.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0, left: 4.0),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16.0,
                        color: Colors.blue,
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  _checkEmail() async {
    bool isValid = await UserBloc().checkEmail(email);
    if (isValid) {
      emailEntered = true;
      newUser = !(await UserBloc().checkUser(email));
      setState(() {});
    } else {
      showPlatformDialog(
        context: context,
        builder: (context) {
          return PlatformAlertDialog(
            title: Text('Invalid Email'),
            content:
                Text("Please enter the email you used to buy your membership."),
            actions: [
              PlatformDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
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
        _continueToHome();
      }
    } on FirebaseAuthException catch (e) {
      setState(() => loading = false);

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

  _continueToHome() async {
    if (loading) {
      return;
    }

    loading = true;

    try {
      await UserBloc().saveUserData();

      loadingFuture = Future.wait([
        ExerciseBloc().fetchExerciseData(),
        NutritionBloc().fetchNutritionData(),
        ProductCategoriesBloc().fetchCategories(),
        LifestyleBloc().fetchLifestyleData(),
        UserBloc().loadUserInfo(),
        GoalBloc().fetchGoals(),
        if (UserBloc().fbUser.uid != AppBloc().adminId)
          MessageBloc().loadMessages(),
        if (UserBloc().fbUser.uid == AppBloc().adminId)
          MessageBloc().loadUsers(),
      ]);

      await loadingFuture;
    } catch (e) {
      setState(() => loading = false);
      showPlatformDialog(
        context: context,
        builder: (context) {
          return PlatformAlertDialog(
            title: Text('There was an error.'),
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
    }

    Get.offAllNamed('/home', predicate: (route) => false);
  }
}
