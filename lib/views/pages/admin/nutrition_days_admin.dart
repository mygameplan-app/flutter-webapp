import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/nutrition_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/constants.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_day.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_program.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/days_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/nutrition_days_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/product_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/reorderableFirebaseList.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';
import 'package:jdarwish_dashboard_web/views/pages/admin/meals_admin.dart';
import 'package:uuid/uuid.dart';

class NutritionDaysAdmin extends StatefulWidget {
  final NutritionProgram nutritionProgram;

  NutritionDaysAdmin({@required this.nutritionProgram});

  MyNutritionDaysAdmin createState() => MyNutritionDaysAdmin();
}

class MyNutritionDaysAdmin extends State<NutritionDaysAdmin> {
  //Variables
  List<NutritionDay> nutritionDays = [];
  bool isReordering = false;

  //ListView
  Column loadListView(QuerySnapshot querySnapshot, String id) {
    nutritionDays = querySnapshot.docs
        .map<NutritionDay>(
            (day) => NutritionDay.fromJson(day.data())..id = day.id)
        .toList();

    List<Widget> containers = [];
    containers.add(Center(
      child: Container(
        height: 100,
        width: 300,
        child: LongButton(
          text: 'Add Nutrition Day',
          icon: Icons.add,
          color: Colors.red,
          textColor: Colors.white,
          onPressed: () {
            NutritionDaysPopup nutritionDaysPopup = NutritionDaysPopup(
                count: nutritionDays.length,
                popUpFunctions: PopUpFunctions.add,
                id: widget.nutritionProgram.id);
            Navigator.push(context,
                TransparentRoute(builder: (context) => nutritionDaysPopup));
          },
        ),
      ),
    ));
    int counter = 0;
    for (NutritionDay day in nutritionDays) {
      containers.add(Container(
        height: 70,
        width: MediaQuery.of(context).size.width,
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
                    builder: (context) => MealAdmin(
                        nutritionDay: day,
                        nutritionProgram: widget.nutritionProgram)));
          },
          leading: SizedBox(
            width: 150,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20,
                    ),
                    onSelected: (Functions result) {
                      doPopUp(result, day);
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
                ),
                Image.network(
                  day.imageUrl,
                  height: 60,
                  width: 80,
                  fit: BoxFit.cover,
                )
              ],
            ),
          ),
          title: Text(day.title,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          subtitle: Text(day.subtitle,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.normal)),
          trailing: Icon(
            Icons.navigate_next,
            size: 25,
            color: Colors.grey,
          ),
        ),
      ));
      counter += 1;
    }
    return Column(children: containers);
  }

  void doPopUp(Functions result, NutritionDay nutritionDay) async {
    switch (result) {
      case Functions.delete:
        await FirebaseFirestore.instance
            .collection('apps')
            .doc(appId)
            .collection('nutritionPrograms')
            .doc(widget.nutritionProgram.id)
            .collection('days')
            .doc(nutritionDay.id)
            .delete();

        return;
      case Functions.edit:
        NutritionDaysPopup nutritionDaysPopup = NutritionDaysPopup(
            popUpFunctions: PopUpFunctions.edit,
            count: nutritionDays.length,
            nutritionday: nutritionDay,
            id: widget.nutritionProgram.id);
        await Navigator.push(context,
            TransparentRoute4(builder: (context) => nutritionDaysPopup));

        return;
      case Functions.duplicate:
        NutritionDay newnutritionDay = nutritionDay;
        newnutritionDay.id = Uuid().v1();
        newnutritionDay.order =
            nutritionDays != null ? nutritionDays.length : 0;
        print(nutritionDays.length);
        NutritionBloc()
            .addNutritionDay(newnutritionDay, widget.nutritionProgram.id);
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

  StreamBuilder daysFetcher() {
    Query daysQuery = FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('nutritionPrograms')
        .doc(widget.nutritionProgram.id)
        .collection('days')
        .orderBy('order');
    return StreamBuilder<QuerySnapshot>(
      stream: daysQuery.snapshots(),
      builder: (context, stream) {
        if (stream.hasData == false) {
          return Center(
            child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)),
          );
        } else if (stream.hasError) {
          return Center(child: Text(stream.error.toString()));
        } else if (stream.hasData == true) {
          QuerySnapshot querySnapshot = stream.data;
          if (querySnapshot.docs.length == 0) {
            return Padding(
              padding: EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 38.0,
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 270.0,
                    child: Text(
                      "No Nutrition Days added.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    height: 100,
                    width: 300,
                    child: LongButton(
                      text: 'Add Nutrition Days',
                      icon: Icons.edit,
                      color: Colors.red,
                      textColor: Colors.white,
                      onPressed: () async {
                        NutritionDaysPopup nutritionDaysPopup =
                            NutritionDaysPopup(
                                popUpFunctions: PopUpFunctions.add,
                                count: nutritionDays.length,
                                id: widget.nutritionProgram.id);
                        await Navigator.push(
                            context,
                            TransparentRoute(
                                builder: (context) => nutritionDaysPopup));
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
                width: 500,
                child: loadListView(querySnapshot, widget.nutritionProgram.id));
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)));
        }
      },
    );
  }

  Widget reorderable() {
    ListTile getlistTile(NutritionDay nutritionDay, int index) {
      return ListTile(
        key: Key(index.toString()),
        leading: Image.network(
          nutritionDay.imageUrl,
          height: 60,
          width: 80,
          fit: BoxFit.cover,
        ),
        title: Text(nutritionDay.title),
        subtitle: Text(nutritionDay.subtitle),
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
            .collection('nutritionPrograms')
            .doc(widget.nutritionProgram.id)
            .collection('days'),
        indexKey: 'order',
        itemBuilder: (BuildContext context, int index, DocumentSnapshot doc) {
          return getlistTile(
              NutritionDay.fromJson(doc.data())..id = doc.id, index);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.nutritionProgram.name} Days'),
        centerTitle: true,
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
                children: [div1(), daysFetcher()],
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
