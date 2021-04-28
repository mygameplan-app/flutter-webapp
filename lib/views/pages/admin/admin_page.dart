import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/product_category.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/admin/settings_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';

class AdminPage extends StatefulWidget {
  MyAdminPage createState() => MyAdminPage();
}

class MyAdminPage extends State<AdminPage> {
  List<ProductCategory> productCategories = [];

  //Product Categories Stream

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'General Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Image.network(
              AppBloc().backgroundUrl,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
            ListView(
              children: [
                SizedBox(
                  height: 20,
                ),
                div1(),
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 10, bottom: 20),
                    height: 140,
                    width: 290,
                    child: LongButton(
                      text: 'Edit Background/ Logo',
                      icon: Icons.edit,
                      color: Colors.red,
                      textColor: Colors.white,
                      onPressed: () {
                        SettingsPopup settingsPopUp = SettingsPopup();
                        Get.dialog(Container());
                        Navigator.push(
                            context,
                            TransparentRoute(
                                builder: (context) => settingsPopUp));
                      },
                    ),
                  ),
                ),
                div1(),
              ],
            ),
          ],
        ));
  }

  Widget div1() {
    return Divider(
      color: Colors.grey,
      height: 1,
      thickness: 1,
    );
  }
}
