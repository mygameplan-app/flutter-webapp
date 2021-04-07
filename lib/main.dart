import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdarwish_dashboard_web/router.dart' as RouterClass;
import 'package:jdarwish_dashboard_web/views/login.dart';
import 'package:jdarwish_dashboard_web/views/unknown_Route_page.dart';

void main() {
  print('Hi');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      unknownRoute: GetPage(name: '/notfound', page: () => UnknownRoutePage()),
      onGenerateRoute: RouterClass.Router.generateRoute,
      navigatorKey: Get.key,
      title: 'Hodgson Fitness',
      theme: ThemeData.dark().copyWith(
        textTheme:
            GoogleFonts.openSansTextTheme(ThemeData.dark().textTheme).copyWith(
          headline4: TextStyle(
            fontFamily: GoogleFonts.roboto().fontFamily,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 24.0,
          ),
        ),
        splashColor: Colors.transparent,
      ),
      builder: (context, child) => child,
      home: LoginView(),
    );
  }
}
