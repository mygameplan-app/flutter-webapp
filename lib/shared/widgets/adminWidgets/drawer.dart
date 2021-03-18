import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jdarwish_dashboard_web/views/home_view.dart';
import 'package:jdarwish_dashboard_web/views/pages/admin/admin_page.dart';
import 'package:jdarwish_dashboard_web/views/pages/admin/nutrition_admin.dart';
import 'package:jdarwish_dashboard_web/views/pages/admin/product_admin.dart';
import 'package:jdarwish_dashboard_web/views/pages/admin/workouts_admin.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class AdminDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: Drawer(
            elevation: 0,
            child: Stack(children: [
              BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 5.0,
                      sigmaY:
                          5.0), //this is dependent on the import statment above
                  child: Container(
                      decoration: BoxDecoration(color: Colors.black))),
              ListView(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 25,
                    ),
                    title: Text('General Settings'),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AdminPage()));
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      FontAwesomeIcons.dumbbell,
                      color: Colors.white,
                      size: 25,
                    ),
                    title: Text('Edit Workouts'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WorkoutsAdmin()));
                    },
                  ),
                  ListTile(
                      leading: Icon(
                        LineAwesomeIcons.cutlery,
                        color: Colors.white,
                        size: 25,
                      ),
                      title: Text('Edit Nutrition'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    NutritionCategoriesAdmin()));
                      }),
                  ListTile(
                    leading: Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 25,
                    ),
                    title: Text('Edit Products'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductCategoriesAdmin()));
                    },
                  ),
                ],
              )
            ])));
  }
}
