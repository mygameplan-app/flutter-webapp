import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdarwish_dashboard_web/router.dart' as RouterClass;
import 'package:jdarwish_dashboard_web/shared/models/message.dart';
import 'package:jdarwish_dashboard_web/shared/models/training_day.dart';
import 'package:jdarwish_dashboard_web/views/home_view.dart';
import 'package:jdarwish_dashboard_web/views/login.dart';
import 'package:jdarwish_dashboard_web/views/pages/conversations_page.dart';
import 'package:jdarwish_dashboard_web/views/pages/custom_video_player.dart';
import 'package:jdarwish_dashboard_web/views/pages/exercise_page.dart';
import 'package:jdarwish_dashboard_web/views/pages/goals_page.dart';
import 'package:jdarwish_dashboard_web/views/pages/messages_page.dart';
import 'package:jdarwish_dashboard_web/views/pages/profile/account_info.dart';
import 'package:jdarwish_dashboard_web/views/pages/profile_page.dart';
import 'package:jdarwish_dashboard_web/views/tabs/nutrition_day_view.dart';
import 'package:jdarwish_dashboard_web/views/tabs/training_day_view.dart';
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
      debugShowCheckedModeBanner: false,
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
