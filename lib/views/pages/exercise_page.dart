import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';

import 'package:jdarwish_dashboard_web/shared/blocs/user_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/exercise.dart';
import 'package:jdarwish_dashboard_web/shared/models/user_data.dart';
import 'package:jdarwish_dashboard_web/shared/navigate_helpers.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/rounded_button.dart';

import 'custom_video_player.dart';

class ExercisePage extends StatefulWidget {
  final Exercise exercise;

  ExercisePage({this.exercise});

  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  UserData userData;
  ExerciseSet newSet = ExerciseSet();
  ExerciseHistory todaySets;
  ExerciseHistory lastSets;

  @override
  void initState() {
    this.userData = UserBloc().userData;
    this._parseHistories();

    super.initState();
  }

  _parseHistories() {
    List<ExerciseHistory> histories = userData.histories
        .where((history) => history.exerciseId == widget.exercise.id)
        .toList()
          ..sort((a, b) => a.date.compareTo(b.date) * -1);

    todaySets = histories.firstWhere((history) {
      return history.date.difference(DateTime.now()).abs() < Duration(hours: 2);
    }, orElse: () => null);

    lastSets = histories.firstWhere((history) {
      return history.date.difference(DateTime.now()).abs() > Duration(hours: 2);
    }, orElse: () => null);

    if (todaySets != null) {
      todaySets.sets.sort((a, b) => a.date.compareTo(b.date));
    }

    if (lastSets != null) {
      lastSets.sets.sort((a, b) => a.date.compareTo(b.date));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.exercise.title),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  color: Colors.white.withOpacity(0.75),
                ),
                margin: EdgeInsets.all(18.0),
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 3, color: Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed('/exercisevideo',
                                arguments: widget.exercise.videoUrl);
                          },
                          child: Image.network(
                            widget.exercise.imageUrl,
                            width: 95,
                            height: 95,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Text(
                              widget.exercise.description ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        )
                      ],
                    ),
                    _exerciseHistory(),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  _exerciseHistory() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.0),
                      ),
                    ),
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('Last Time', textAlign: TextAlign.center),
                        ),
                        Expanded(
                          child: Text('Today', textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _historySide(true),
                        ),
                        VerticalDivider(color: Colors.grey),
                        Expanded(
                          child: _historySide(false),
                        ),
                      ],
                    ),
                  ),
                  RoundedButton(
                    child: Text('Add Set'),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return _modalContent();
                          });
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _historySide(bool lastTime) {
    ExerciseHistory history = lastTime ? lastSets : todaySets;

    return Container(
      padding: EdgeInsets.only(
        left: lastTime ? 8.0 : 0.0,
        right: lastTime ? 0.0 : 8.0,
        top: 8.0,
        bottom: 12.0,
      ),
      child: Column(
        children: [
          if (history != null)
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Reps',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      for (ExerciseSet s in history.sets)
                        Text(
                          s.reps.toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Weight',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      for (ExerciseSet s in history.sets)
                        Text(
                          s.weight.toString(),
                          style: TextStyle(color: Colors.black),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          if (history == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28.0),
              child: Text(
                lastTime
                    ? 'No previous sets recorded'
                    : 'Add a Set to record your workout',
                style: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            )
        ],
      ),
    );
  }

  _showIOSSheet() {}

  _showAndroidSheet() {}

  _modalContent() {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: Text('Add Set'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Theme.of(context).cardColor,
            actions: [
              Padding(
                padding: EdgeInsets.all(0.0),
                child: FlatButton(
                  child: Text('Save'),
                  onPressed: () async {
                    await UserBloc().addSet(
                      widget.exercise,
                      this.newSet.reps,
                      this.newSet.weight,
                    );
                    this.userData = UserBloc().userData;
                    _parseHistories();
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
            leading: FlatButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            leadingWidth: 100.0,
          ),
          SizedBox(height: 14.0),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reps'),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (s) =>
                        setState(() => newSet.reps = int.parse(s)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weight'),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (s) =>
                        setState(() => newSet.weight = double.parse(s)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 300),
        ],
      ),
    );
  }
}
