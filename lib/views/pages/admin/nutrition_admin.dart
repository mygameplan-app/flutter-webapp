import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/nutrition_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_program.dart';

import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/drawer.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/nutrition_categoires_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/reorderableFirebaseList.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/product_popup.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui';
import 'package:jdarwish_dashboard_web/shared/constants.dart';
import 'nutrition_days_admin.dart';

class NutritionCategoriesAdmin extends StatefulWidget {
  MyNutritionCategoriesAdmin createState() => MyNutritionCategoriesAdmin();
}

class MyNutritionCategoriesAdmin extends State<NutritionCategoriesAdmin> {
  NutritionBloc nutritionBloc = NutritionBloc();
  List<NutritionProgram> nutritionPrograms = [];
  bool isReordering = false;
  //Product Categories Stream
  StreamBuilder categoriesFetcher() {
    void doPopUp(Functions1 result, NutritionProgram nutritionProgram) async {
      switch (result) {
        case Functions1.Delete:
          await FirebaseFirestore.instance
              .collection('apps')
              .doc(appId)
              .collection('nutritionPrograms')
              .doc(nutritionProgram.id)
              .delete();
          return;
        case Functions1.Edit:
          NutritionCategoryPopup nutritionCategoryPopup =
              NutritionCategoryPopup(
            count: nutritionPrograms.length,
            popUpFunctions: PopUpFunctions.Edit,
            nutritionProgram: nutritionProgram,
          );
          await Navigator.push(context,
              TransparentRoute(builder: (context) => nutritionCategoryPopup));

          return;
        case Functions1.Duplicate:
          NutritionBloc nutritionbloc = NutritionBloc();
          NutritionProgram newNutritionProgram = nutritionProgram;
          newNutritionProgram.id = Uuid().v1();
          newNutritionProgram.order =
            nutritionPrograms != null ? nutritionPrograms.length : 0;
          nutritionbloc.addNutritionProgram(newNutritionProgram);
          return;
        case Functions1.ReOrder:
          setState(() {
            isReordering = true;
          });
          return;
        default:
          return;
      }
    }

    Column getListView() {
      List<Widget> containers = [];
      int counter = 0;
      for (NutritionProgram nutritionProgram in nutritionPrograms) {
        containers.add(Container(
          height: 50,
          decoration: BoxDecoration(
              color: Colors.white10,
              border: Border(
                  top: counter == 0
                      ? BorderSide(color: Colors.grey, width: 1)
                      : BorderSide(color: Colors.transparent, width: 0),
                  bottom: BorderSide(color: Colors.grey, width: 1))),
          child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NutritionDaysAdmin(
                              nutritionProgram: nutritionProgram,
                            )));
              },
              title: Text(nutritionProgram.name),
              leading: PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 20,
                ),
                onSelected: (Functions1 result) {
                  doPopUp(result, nutritionProgram);
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<Functions1>>[
                  const PopupMenuItem<Functions1>(
                    value: Functions1.Edit,
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem<Functions1>(
                    value: Functions1.Duplicate,
                    child: Text('Duplicate'),
                  ),
                  const PopupMenuItem<Functions1>(
                    value: Functions1.Delete,
                    child: Text('Delete'),
                  ),
                  const PopupMenuItem<Functions1>(
                      value: Functions1.ReOrder, child: Text('Reorder'))
                ],
              ),
              trailing: Icon(
                Icons.navigate_next,
                size: 25,
                color: Colors.grey,
              )),
        ));
        counter += 1;
      }
      return Column(children: containers);
    }

    Query query = FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('nutritionPrograms')
        .orderBy('order');
    return StreamBuilder(
        stream: query.snapshots(),
        builder: (context, stream) {
          if (stream.hasData == false) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.white)));
          } else if (stream.hasError) {
            return Center(child: Text(stream.error.toString()));
          } else if (stream.hasData == true) {
            QuerySnapshot querySnapshot = stream.data;

            nutritionPrograms = querySnapshot.docs
                .map<NutritionProgram>((nutritionprogram2) =>
                    NutritionProgram.fromJson(nutritionprogram2.data()))
                .toList();

            return Column(children: [
              Container(
                height: 100,
                width: 300,
                child: LongButton(
                  text: 'Add Nutrition Program',
                  icon: Icons.add,
                  color: Colors.red,
                  textColor: Colors.white,
                  onPressed: () {
                    NutritionCategoryPopup nutritionCategoryPopup =
                        NutritionCategoryPopup(
                      count: nutritionPrograms.length,
                      popUpFunctions: PopUpFunctions.Add,
                    );
                    Navigator.push(
                        context,
                        TransparentRoute(
                            builder: (context) => nutritionCategoryPopup));
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: getListView(),
              ),
            ]);
          } else {
            return Container();
          }
        });
  }

  Widget reorderable() {
    ListTile getlistTile(NutritionProgram nutritionProgram, int index) {
      return ListTile(
        key: Key(index.toString()),
        leading: Text(nutritionProgram.name),
        trailing: Icon(
          Icons.reorder,
          size: 30,
          color: Colors.white,
        ),
      );
    }

    return ReorderableFirebaseList(
        collection: FirebaseFirestore.instance
            .collection('apps')
            .doc(appId)
            .collection('nutritionPrograms'),
        indexKey: 'order',
        itemBuilder: (BuildContext context, int index, DocumentSnapshot doc) {
          return getlistTile(NutritionProgram.fromJson(doc.data()), index);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Nutrition Programs'),
        centerTitle: true,
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          isReordering
              ? TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    setState(() {
                      isReordering = false;
                    });
                  },
                )
              : Container()
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        Image.network(
          AppBloc().backgroundUrl,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.3),
          colorBlendMode: BlendMode.darken,
        ),
        isReordering
            ? SafeArea(child: reorderable())
            : ListView(
                children: [div1(), categoriesFetcher()],
              )
      ]),
    );
  }

  Widget div1() {
    return Divider(
      color: Colors.grey,
      height: 1,
      thickness: 1,
    );
  }
}
