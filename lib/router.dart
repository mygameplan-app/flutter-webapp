import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdarwish_dashboard_web/views/home_view.dart';
import 'package:jdarwish_dashboard_web/views/login.dart';
import 'package:jdarwish_dashboard_web/views/pages/conversations_page.dart';
import 'package:jdarwish_dashboard_web/views/pages/custom_video_player.dart';
import 'package:jdarwish_dashboard_web/views/pages/exercise_page.dart';
import 'package:jdarwish_dashboard_web/views/pages/messages_page.dart';
import 'package:jdarwish_dashboard_web/views/pages/profile_page.dart';
import 'package:jdarwish_dashboard_web/views/tabs/nutrition_day_view.dart';
import 'package:jdarwish_dashboard_web/views/tabs/training_day_view.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return GetPageRoute(
          settings: settings,
          page: () => LoginView(),
        );

      case '/profilepage':
        return GetPageRoute(
          settings: settings,
          page: () => ProfilePage(),
        );

      case '/exercises':
        return GetPageRoute(
          settings: settings,
          page: () => ExercisePage(),
        );
      case '/trainingdays':
        return GetPageRoute(
          settings: settings,
          page: () => TrainingDayView(),
        );
      case '/nutritiondays':
        return GetPageRoute(
          settings: settings,
          page: () => NutritionDayView(),
        );
      case '/conversations':
        return GetPageRoute(
          settings: settings,
          page: () => ConversationsPage(),
        );
      case '/messages':
        return GetPageRoute(
          settings: settings,
          page: () => MessagesPage(),
        );
      case '/home':
        return GetPageRoute(
          settings: settings,
          page: () => HomeView(),
        );
      //You can define a different page for routes with arguments, and another without arguments, but for that you must use the slash '/' on the route that will not receive arguments as above.
      case '/profile':
        return GetPageRoute(
          settings: settings,
          page: () => ProfilePage(),
        );
      case '/exercisevideo':
        return GetPageRoute(
          settings: settings,
          page: () => YoutubeVideoPlayer(),
        );
    }
  }
}
