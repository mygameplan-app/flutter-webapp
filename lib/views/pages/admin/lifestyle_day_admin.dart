import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/lifestyle_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/constants.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_day.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_program.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/days_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/lifestyle_day_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/product_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/reorderableFirebaseList.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';
import 'package:jdarwish_dashboard_web/views/pages/admin/meals_admin.dart';
import 'package:uuid/uuid.dart';

import 'lifestyle_admin.dart';

class LifestyleDaysAdmin extends StatefulWidget {
  final LifestyleProgram lifestyleProgram;

  LifestyleDaysAdmin({@required this.lifestyleProgram});

  MyLifestyleDaysAdmin createState() => MyLifestyleDaysAdmin();
}

class MyLifestyleDaysAdmin extends State<LifestyleDaysAdmin> {
  //Variables
  List<LifestyleDay> lifestyleDays = [];
  bool isReordering = false;

  //ListView
  Column loadListView(QuerySnapshot querySnapshot, String id) {
    lifestyleDays = querySnapshot.docs
        .map<LifestyleDay>((day) => LifestyleDay.fromJson(day.data())..id = day.id)
        .toList();

    List<Widget> containers = [];
    containers.add(Center(
      child: Container(
        height: 100,
        width: 300,
        child: LongButton(
          text: 'Add Lifestyle Day',
          icon: Icons.add,
          color: Colors.red,
          textColor: Colors.white,
          onPressed: () {
            LifestyleDaysPopup lifestyleDaysPopup = LifestyleDaysPopup(
                count: lifestyleDays.length,
                popUpFunctions: PopUpFunctions.add,
                id: widget.lifestyleProgram.id);
            Navigator.push(context,
                TransparentRoute(builder: (context) => lifestyleDaysPopup));
          },
        ),
      ),
    ));
    int counter = 0;
    for (LifestyleDay day in lifestyleDays) {
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
                    builder: (context) => LifestyleAdmin(
                        lifestyleDay: day,
                        lifestyleProgram: widget.lifestyleProgram),),);
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

  void doPopUp(Functions result, LifestyleDay lifestyleDay) async {
    switch (result) {
      case Functions.delete:
        await FirebaseFirestore.instance
            .collection('apps')
            .doc(appId)
            .collection('lifestyle')
            .doc(widget.lifestyleProgram.id)
            .collection('days')
            .doc(lifestyleDay.id)
            .delete();

        return;
      case Functions.edit:
        LifestyleDaysPopup lifestyleDaysPopup = LifestyleDaysPopup(
            popUpFunctions: PopUpFunctions.edit,
            count: lifestyleDays.length,
            lifestyleday: lifestyleDay,
            id: widget.lifestyleProgram.id);
        await Navigator.push(context,
            TransparentRoute4(builder: (context) => lifestyleDaysPopup));

        return;
      case Functions.duplicate:
        LifestyleDay newlifestyleDay = lifestyleDay;
        newlifestyleDay.id = Uuid().v1();
        newlifestyleDay.order =
        lifestyleDays != null ? lifestyleDays.length : 0;
        print(lifestyleDays.length);
        LifestyleBloc()
            .addLifestyleDay(newlifestyleDay, widget.lifestyleProgram.id);
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
        .collection('lifestyle')
        .doc(widget.lifestyleProgram.id)
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
                      "No Lifestyle Days added.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    height: 100,
                    width: 300,
                    child: LongButton(
                      text: 'Add Lifestyle Days',
                      icon: Icons.edit,
                      color: Colors.red,
                      textColor: Colors.white,
                      onPressed: () async {
                        LifestyleDaysPopup lifestyleDaysPopup =
                        LifestyleDaysPopup(
                            popUpFunctions: PopUpFunctions.add,
                            count: lifestyleDays.length,
                            id: widget.lifestyleProgram.id);
                        await Navigator.push(
                            context,
                            TransparentRoute(
                                builder: (context) => lifestyleDaysPopup));
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
                width: 500,
                child: loadListView(querySnapshot, widget.lifestyleProgram.id));
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
    ListTile getlistTile(LifestyleDay lifestyleDay, int index) {
      return ListTile(
        key: Key(index.toString()),
        leading: Image.network(
          lifestyleDay.imageUrl,
          height: 60,
          width: 80,
          fit: BoxFit.cover,
        ),
        title: Text(lifestyleDay.title),
        subtitle: Text(lifestyleDay.subtitle),
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
            .collection('lifestyle')
            .doc(widget.lifestyleProgram.id)
            .collection('days'),
        indexKey: 'order',
        itemBuilder: (BuildContext context, int index, DocumentSnapshot doc) {
          return getlistTile(LifestyleDay.fromJson(doc.data()), index);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.lifestyleProgram.name} Days'),
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
