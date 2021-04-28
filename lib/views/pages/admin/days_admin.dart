import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/exercise_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/constants.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/program.dart';
import 'package:jdarwish_dashboard_web/shared/models/training_day.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/admin/days_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/admin/product_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/admin/reorderableFirebaseList.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';
import 'package:uuid/uuid.dart';

import 'exercises_admin.dart';

class DaysAdmin extends StatefulWidget {
  final Program program;

  DaysAdmin({@required this.program});

  MyDaysAdmin createState() => MyDaysAdmin();
}

class MyDaysAdmin extends State<DaysAdmin> {
  List<TrainingDay> days = [];
  bool isReordering = false;

  Column loadListView(QuerySnapshot querySnapshot, String id) {
    days = querySnapshot.docs
        .map<TrainingDay>(
            (day) => TrainingDay.fromJson(day.data())..id = day.id)
        .toList();
    List<Widget> containers = [];
    containers.add(Container(
      height: 100,
      width: 240,
      child: LongButton(
        text: 'Add Day',
        icon: Icons.add,
        color: Colors.red,
        textColor: Colors.white,
        onPressed: () {
          DaysPopup daysPopup = DaysPopup(
            popUpFunctions: PopUpFunctions.add,
            id: widget.program.id,
            count: days.length,
          );
          Navigator.push(
              context, TransparentRoute(builder: (context) => daysPopup));
        },
      ),
    ));
    int counter = 0;
    for (TrainingDay day in days) {
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
                    builder: (context) => ExerciseAdmin(
                        trainingDay: day, program: widget.program)));
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

  void doPopUp(Functions result, TrainingDay trainingDay) async {
    switch (result) {
      case Functions.delete:
        await FirebaseFirestore.instance
            .collection('apps')
            .doc(appId)
            .collection('exercisePrograms')
            .doc(widget.program.id)
            .collection('days')
            .doc(trainingDay.id)
            .delete();
        return;
      case Functions.edit:
        print(widget.program.id);
        DaysPopup daysPopup = DaysPopup(
            popUpFunctions: PopUpFunctions.edit,
            trainingday: trainingDay,
            id: widget.program.id,
            count: days.length);
        await Navigator.push(
            context, TransparentRoute4(builder: (context) => daysPopup));
        return;

      case Functions.duplicate:
        TrainingDay newtrainingDay = trainingDay;
        newtrainingDay.id = Uuid().v1();
        newtrainingDay.order = trainingDay.order;
        ExerciseBloc().addTrainingDay(newtrainingDay, widget.program.id);
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

  //Product Stream
  StreamBuilder daysFetcher() {
    Query daysQuery = FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('exercisePrograms')
        .doc(widget.program.id)
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
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 38.0,
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 270.0,
                    child: Text(
                      "No Days added.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    height: 100,
                    width: 220,
                    child: LongButton(
                      text: 'Add Days',
                      icon: Icons.edit,
                      color: Colors.red,
                      textColor: Colors.white,
                      onPressed: () async {
                        DaysPopup daysPopup = DaysPopup(
                            popUpFunctions: PopUpFunctions.add,
                            id: widget.program.id,
                            count: days.length);
                        await Navigator.push(context,
                            TransparentRoute(builder: (context) => daysPopup));
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
                width: 500,
                child: loadListView(querySnapshot, widget.program.id));
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
    ListTile getlistTile(TrainingDay day, int index) {
      return ListTile(
        key: Key(index.toString()),
        leading: Image.network(
          day.imageUrl,
          height: 60,
          width: 80,
          fit: BoxFit.cover,
        ),
        title: Text(day.title),
        subtitle: Text(day.subtitle),
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
            .collection('exercisePrograms')
            .doc(widget.program.id)
            .collection('days'),
        indexKey: 'order',
        itemBuilder: (BuildContext context, int index, DocumentSnapshot doc) {
          return getlistTile(
              TrainingDay.fromJson(doc.data())..id = doc.id, index);
        });
  }

  void updateListinFirestore() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.program.name} Days'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
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
