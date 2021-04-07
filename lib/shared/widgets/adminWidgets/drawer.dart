import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jdarwish_dashboard_web/views/pages/admin/admin_page.dart';
import 'package:jdarwish_dashboard_web/views/pages/admin/lifestyle_program_admin.dart';
import 'package:jdarwish_dashboard_web/views/pages/admin/nutrition_admin.dart';
import 'package:jdarwish_dashboard_web/views/pages/admin/product_admin.dart';
import 'package:jdarwish_dashboard_web/views/pages/admin/workouts_admin.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class AdminDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.settings, color: Colors.white, size: 25),
            title: Text('General Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminPage()),
              );
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
                MaterialPageRoute(builder: (context) => WorkoutsAdmin()),
              );
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
                  builder: (context) => NutritionCategoriesAdmin(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              LineAwesomeIcons.heart_o,
              color: Colors.white,
              size: 25,
            ),
            title: Text('Edit Lifestyle Items'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LifestyleCategoriesAdmin(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.store, color: Colors.white, size: 25),
            title: Text('Edit Products'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductCategoriesAdmin(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
