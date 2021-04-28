import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/exercise_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/constants.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/program.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/admin/program_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/admin/reorderableFirebaseList.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';
import 'package:uuid/uuid.dart';

import 'days_admin.dart';

class WorkoutsAdmin extends StatefulWidget {
  MyWorkoutsAdmin createState() => MyWorkoutsAdmin();
}

class MyWorkoutsAdmin extends State<WorkoutsAdmin> {
  bool isReordering = false;
  List<Program> programs = [];

  StreamBuilder courseFetcher() {
    void doPopUp(Functions result, Program program) async {
      switch (result) {
        case Functions.delete:
          await FirebaseFirestore.instance
              .collection('apps')
              .doc(appId)
              .collection('exercisePrograms')
              .doc(program.id)
              .delete();

          return;
        case Functions.edit:
          ProgramPopup programPopup = ProgramPopup(
            popUpFunctions: PopUpFunctions.edit,
            count: programs.length,
            program: program,
          );
          await Navigator.push(
              context, TransparentRoute2(builder: (context) => programPopup));

          return;
        case Functions.duplicate:
          Program newProgram = program;
          newProgram.id = Uuid().v1();
          newProgram.order = programs != null ? programs.length : 0;
          ExerciseBloc().addProgram(newProgram);
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
      for (Program program in programs) {
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
                        builder: (context) => DaysAdmin(program: program)));
              },
              title: Text(program.name),
              leading: PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 20,
                ),
                onSelected: (Functions result) {
                  doPopUp(result, program);
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

    Query programQuery = FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('exercisePrograms')
        .orderBy('order');
    return StreamBuilder(
        stream: programQuery.snapshots(),
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
            programs = querySnapshot.docs
                .map<Program>((program) =>
                    Program.fromJson(program.data())..id = program.id)
                .toList();

            return Column(children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                height: 100,
                width: 250,
                child: LongButton(
                  text: 'Add Workout',
                  icon: Icons.add,
                  color: Colors.red,
                  textColor: Colors.white,
                  onPressed: () {
                    ProgramPopup programPopup = ProgramPopup(
                      popUpFunctions: PopUpFunctions.add,
                      count: programs.length,
                    );
                    Navigator.push(context,
                        TransparentRoute2(builder: (context) => programPopup));
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 20),
                child: getListView(),
              ),
            ]);
          } else {
            return Container();
          }
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget reorderable() {
    ListTile getlistTile(Program program, int index) {
      return ListTile(
        key: Key(index.toString()),
        leading: Text(program.name),
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
            .collection('exercisePrograms'),
        indexKey: 'order',
        itemBuilder: (BuildContext context, int index, DocumentSnapshot doc) {
          return getlistTile(Program.fromJson(doc.data())..id = doc.id, index);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Workouts'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
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
                children: [div1(), courseFetcher()],
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
