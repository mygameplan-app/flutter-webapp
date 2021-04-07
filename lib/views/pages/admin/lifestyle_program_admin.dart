import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/lifestyle_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/constants.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_program.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/lifestyle_program_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/product_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/reorderableFirebaseList.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';
import 'package:jdarwish_dashboard_web/views/pages/admin/lifestyle_day_admin.dart';
import 'package:uuid/uuid.dart';

class LifestyleCategoriesAdmin extends StatefulWidget {
  MyLifestyleCategoriesAdmin createState() => MyLifestyleCategoriesAdmin();
}

class MyLifestyleCategoriesAdmin extends State<LifestyleCategoriesAdmin> {
  List<LifestyleProgram> lifestylePrograms = [];
  bool isReordering = false;

  //Product Categories Stream
  StreamBuilder categoriesFetcher() {
    void doPopUp(Functions result, LifestyleProgram lifestyleProgram) async {
      switch (result) {
        case Functions.delete:
          await FirebaseFirestore.instance
              .collection('apps')
              .doc(appId)
              .collection('lifestyle')
              .doc(lifestyleProgram.id)
              .delete();
          return;
        case Functions.edit:
          LifestyleCategoryPopup lifestyleCategoryPopup =
              LifestyleCategoryPopup(
            count: lifestylePrograms.length,
            popUpFunctions: PopUpFunctions.edit,
            lifestyleProgram: lifestyleProgram,
          );
          await Navigator.push(context,
              TransparentRoute(builder: (context) => lifestyleCategoryPopup));

          return;
        case Functions.duplicate:
          LifestyleProgram newLifestyleProgram = lifestyleProgram;
          newLifestyleProgram.id = Uuid().v1();
          newLifestyleProgram.order =
              lifestylePrograms != null ? lifestylePrograms.length : 0;
          LifestyleBloc().addLifestyleProgram(newLifestyleProgram);
          return;
        case Functions.reorder:
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
      for (LifestyleProgram lifestyleProgram in lifestylePrograms) {
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
                        builder: (context) => LifestyleDaysAdmin(
                              lifestyleProgram: lifestyleProgram,
                            )));
              },
              title: Text(lifestyleProgram.name),
              leading: PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 20,
                ),
                onSelected: (Functions result) {
                  doPopUp(result, lifestyleProgram);
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<Functions>>[
                  const PopupMenuItem<Functions>(
                    value: Functions.edit,
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem<Functions>(
                    value: Functions.duplicate,
                    child: Text('Duplicate'),
                  ),
                  const PopupMenuItem<Functions>(
                    value: Functions.delete,
                    child: Text('Delete'),
                  ),
                  const PopupMenuItem<Functions>(
                      value: Functions.reorder, child: Text('Reorder'))
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
        .collection('lifestyle')
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

            lifestylePrograms = querySnapshot.docs
                .map<LifestyleProgram>((lifestyleprogram2) =>
                    LifestyleProgram.fromJson(lifestyleprogram2.data()))
                .toList();

            return Column(children: [
              Container(
                height: 100,
                width: 300,
                child: LongButton(
                  text: 'Add Lifestyle Program',
                  icon: Icons.add,
                  color: Colors.red,
                  textColor: Colors.white,
                  onPressed: () {
                    LifestyleCategoryPopup lifestyleCategoryPopup =
                        LifestyleCategoryPopup(
                      count: lifestylePrograms.length,
                      popUpFunctions: PopUpFunctions.add,
                    );
                    Navigator.push(
                        context,
                        TransparentRoute(
                            builder: (context) => lifestyleCategoryPopup));
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
    ListTile getlistTile(LifestyleProgram lifestyleProgram, int index) {
      return ListTile(
        key: Key(index.toString()),
        leading: Text(lifestyleProgram.name),
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
            .collection('lifestyle'),
        indexKey: 'order',
        itemBuilder: (BuildContext context, int index, DocumentSnapshot doc) {
          return getlistTile(LifestyleProgram.fromJson(doc.data()), index);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Lifestyle Programs'),
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
