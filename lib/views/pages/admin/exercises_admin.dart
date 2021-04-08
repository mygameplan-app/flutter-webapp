import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/app_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/exercise_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/constants.dart';
import 'package:jdarwish_dashboard_web/shared/models/enums.dart';
import 'package:jdarwish_dashboard_web/shared/models/exercise.dart';
import 'package:jdarwish_dashboard_web/shared/models/program.dart';
import 'package:jdarwish_dashboard_web/shared/models/training_day.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/exercise_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/product_popup.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/adminWidgets/reorderableFirebaseList.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/long_button.dart';
import 'package:uuid/uuid.dart';

class ExerciseAdmin extends StatefulWidget {
  final Program program;
  final TrainingDay trainingDay;

  ExerciseAdmin({
    @required this.program,
    @required this.trainingDay,
  });

  MyExerciseAdmin createState() => MyExerciseAdmin();
}

class MyExerciseAdmin extends State<ExerciseAdmin> {
  //Variables
  List<Exercise> exercises = [];
  bool isReordering = false;

  //ListView
  Column loadListView(QuerySnapshot querySnapshot, String id) {
    exercises = querySnapshot.docs
        .map<Exercise>((exercise) => Exercise.fromJson(exercise.data()))
        .toList();

    List<Widget> containers = [];
    containers.add(Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        height: 100,
        width: 240,
        child: LongButton(
          text: 'Add Exercise',
          icon: Icons.add,
          color: Colors.red,
          textColor: Colors.white,
          onPressed: () {
            ExercisePopup exercisePopup = ExercisePopup(
              popUpFunctions: PopUpFunctions.add,
              count: exercises.length,
              program: widget.program,
              trainingday: widget.trainingDay,
            );
            Navigator.push(
                context, TransparentRoute(builder: (context) => exercisePopup));
          },
        ),
      ),
    ));
    int counter = 0;
    for (Exercise exercise in exercises) {
      containers.add(Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white10,
            border: Border(
                top: counter == 0
                    ? BorderSide(color: Colors.grey, width: 1)
                    : BorderSide(color: Colors.transparent, width: 0),
                bottom: BorderSide(color: Colors.grey, width: 1))),
        child: ListTile(
          leading: Padding(
            padding: EdgeInsets.only(top: 10),
            child: SizedBox(
              width: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
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
                        doPopUp(result, exercise);
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
                    exercise.imageUrl,
                    height: 60,
                    width: 80,
                    fit: BoxFit.cover,
                  )
                ],
              ),
            ),
          ),
          title: Text(exercise.title,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ));
      counter += 1;
    }
    return Column(children: containers);
  }

  Widget reorderable() {
    ListTile getlistTile(Exercise exercise, int index) {
      return ListTile(
        key: Key(index.toString()),
        leading: Image.network(
          exercise.imageUrl,
          height: 60,
          width: 80,
          fit: BoxFit.cover,
        ),
        title: Text(exercise.title),
        subtitle: Text(exercise.subtitle),
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
            .collection('days')
            .doc(widget.trainingDay.id)
            .collection('exercises'),
        indexKey: 'order',
        itemBuilder: (BuildContext context, int index, DocumentSnapshot doc) {
          return getlistTile(Exercise.fromJson(doc.data())..id = doc.id, index);
        });
  }

  void doPopUp(Functions result, Exercise exercise) async {
    switch (result) {
      case Functions.delete:
        await FirebaseFirestore.instance
            .collection('apps')
            .doc(appId)
            .collection('exercisePrograms')
            .doc(widget.program.id)
            .collection('days')
            .doc(widget.trainingDay.id)
            .collection('exercises')
            .doc(exercise.id)
            .delete();

        return;
      case Functions.edit:
        ExercisePopup exercisePopup = ExercisePopup(
          popUpFunctions: PopUpFunctions.edit,
          exercise: exercise,
          count: exercises.length,
          trainingday: widget.trainingDay,
          program: widget.program,
        );
        await Navigator.push(
            context, TransparentRoute5(builder: (context) => exercisePopup));

        return;
      case Functions.duplicate:
        Exercise newExercise = exercise;
        newExercise.id = Uuid().v1();
        newExercise.order = exercises != null ? exercises.length : 0;
        ExerciseBloc()
            .addExercise(widget.trainingDay, widget.program, exercise);
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
  StreamBuilder exercisesFetcher() {
    print(widget.program.id);
    print(widget.trainingDay.id);
    Query exercisesQuery = FirebaseFirestore.instance
        .collection('apps')
        .doc(appId)
        .collection('exercisePrograms')
        .doc(widget.program.id)
        .collection('days')
        .doc(widget.trainingDay.id)
        .collection('exercises')
        .orderBy('order');
    return StreamBuilder<QuerySnapshot>(
      stream: exercisesQuery.snapshots(),
      builder: (context, stream) {
        if (stream.hasData == false) {
          return Center(
              child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)));
        } else if (stream.hasError) {
          return Center(child: Text(stream.error.toString()));
        } else if (stream.hasData == true) {
          QuerySnapshot querySnapshot = stream.data;
          print(querySnapshot.docs.length);
          if (querySnapshot.docs.length == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.dumbbell,
                    color: Colors.white,
                    size: 38,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 240.0,
                    child: Text(
                      "No Exercises added.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    height: 100,
                    width: 240,
                    child: LongButton(
                      text: 'Add Exercises',
                      icon: Icons.add,
                      color: Colors.red,
                      textColor: Colors.white,
                      onPressed: () async {
                        ExercisePopup exercisePopup = ExercisePopup(
                          popUpFunctions: PopUpFunctions.add,
                          program: widget.program,
                          count: exercises.length,
                          trainingday: widget.trainingDay,
                        );
                        await Navigator.push(
                            context,
                            TransparentRoute(
                                builder: (context) => exercisePopup));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.program.name}/ ${widget.trainingDay.title}'),
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
                children: [div1(), exercisesFetcher()],
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
