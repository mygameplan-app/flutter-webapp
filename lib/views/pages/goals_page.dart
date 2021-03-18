import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:jdarwish_dashboard_web/shared/blocs/goal_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/user_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/goal.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/circle_item.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/circle_switcher.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/rounded_button.dart';

class GoalsPage extends StatefulWidget {
  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  Goal selectedGoal;
  GoalBloc goalBloc;
  UserBloc userBloc;
  List<GoalEntry> goalEntries;
  GoalEntry newEntry = GoalEntry(date: DateTime.now());
  TextEditingController dateController = TextEditingController(
    text: _dateToString(DateTime.now()),
  );

  @override
  void initState() {
    goalBloc = GoalBloc();
    userBloc = UserBloc();
    selectedGoal =
        (goalBloc.goals?.isNotEmpty ?? false) ? goalBloc.goals.first : null;

    _getSelectedGoalEntries();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Divider(
              thickness: 1,
              height: 1,
              color: Colors.white.withAlpha(50),
            ),
            Container(
              margin: EdgeInsets.only(top: 24.0, bottom: 14.0),
              child: Text(
                'Goals',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            CircleSwitcher(
              centered: true,
              items: [
                for (Goal goal in goalBloc.goals)
                  CircleItem(
                    title: goal.title,
                    color: goal.color,
                    outlineColor: Colors.white,
                    onTap: () => setState(() {
                      this.selectedGoal = goal;
                      _getSelectedGoalEntries();
                    }),
                    selected: this.selectedGoal.id == goal.id,
                  )
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 14.0),
              height: 48,
              child: TabBar(
                labelPadding: EdgeInsets.all(0.0),
                indicator: BoxDecoration(
                  border:
                      Border(top: BorderSide(width: 3.0, color: Colors.white)),
                ),
                tabs: [
                  _tabItem('Week'),
                  _tabItem('Month'),
                  _tabItem('Year'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [for (int i = 0; i < 3; i++) _graphView(i)],
              ),
            ),
            Divider(thickness: 1.5),
            RoundedButton(
              child: Text('Add Entry'),
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
    );
  }

  Widget _tabItem(String title) {
    return Tab(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withAlpha(50),
                    width: 1.0,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ),
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
            title: Text(
                'Add Entry for ${selectedGoal != null ? selectedGoal.title != null ? selectedGoal.title : 'N/A' : 'N/A'}'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Theme.of(context).cardColor,
            actions: [
              Padding(
                padding: EdgeInsets.all(0.0),
                child: FlatButton(
                  child: Text('Save'),
                  onPressed: () async {
                    try {
                      await UserBloc().addGoalEntry(
                        selectedGoal,
                        this.newEntry.value,
                        this.newEntry.date,
                      );
                      setState(() => _getSelectedGoalEntries());
                      Navigator.of(context).pop();
                    } catch (e) {
                      Navigator.of(context).pop();
                      showPlatformDialog(
                          context: context,
                          builder: (ctx) {
                            return PlatformAlertDialog(
                              content: Text(e.toString()),
                              actions: [
                                PlatformDialogAction(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            );
                          });
                    }
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
                Text('Date'),
                Expanded(
                  child: TextField(
                    controller: dateController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                        lastDate: DateTime.now().add(Duration(days: 1)),
                      ).then((date) {
                        newEntry.date = date;
                        setState(
                          () => dateController.text = _dateToString(date),
                        );
                      });
                    },
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
                Text(selectedGoal != null
                    ? selectedGoal.title != null
                        ? selectedGoal.title
                        : 'N/A'
                    : 'N/A'),
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
                    onChanged: (s) => setState(
                      () => newEntry.value = int.parse(s),
                    ),
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

  static String _dateToString(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  Widget _graphView(int index) {
    List<GoalEntry> goalSublist = [];
    Function(double) getXTitles;
    double horizontalInterval;
    List<FlSpot> spots = [];
    double minX;
    double maxX;

    if (index == 0) {
      goalSublist = goalEntries.where((e) {
        return e.date.isAfter(DateTime.now()
            .subtract(Duration(days: (DateTime.now().weekday % 7) + 1)));
      }).toList();

      getXTitles = (n) => ['S', 'M', 'T', 'W', 'T', 'F', 'S'][n.floor()];
      horizontalInterval = 1;
      spots = [
        for (GoalEntry e in goalSublist)
          FlSpot(e.date.weekday.toDouble() % 7, e.value.toDouble())
      ];
      minX = 0;
      maxX = 6;
    } else if (index == 1) {
      goalSublist = goalEntries.where((e) {
        return e.date.month == DateTime.now().month &&
            e.date.year == DateTime.now().year;
      }).toList();

      horizontalInterval = 5;
      getXTitles = (n) => '${n.floor()}';
      spots = [
        for (GoalEntry e in goalSublist)
          FlSpot(e.date.day.toDouble(), e.value.toDouble())
      ];
      minX = 1;
      maxX = [
        0,
        31,
        29,
        31,
        30,
        31,
        30,
        31,
        31,
        30,
        31,
        30,
        31
      ][DateTime.now().month]
          .toDouble();
    } else {
      goalSublist = goalEntries.where((e) {
        return e.date.year == DateTime.now().year;
      }).toList();

      horizontalInterval = 3;
      getXTitles = (n) => [
            '',
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
            ''
          ][n.floor()];

      minX = 1;
      maxX = 13;

      spots = [
        for (GoalEntry e in goalSublist)
          FlSpot(e.date.month + (e.date.day / 30), e.value.toDouble())
      ];
    }

    spots.sort((a, b) => a.x.compareTo(b.x));
    print(spots);

    double minY = goalSublist.map((e) => e.value.toDouble()).fold(100000, min);
    double maxY = goalSublist.map((e) => e.value.toDouble()).fold(0, max);
    double verticalInterval = max(((maxY - minY) / 8).floor().toDouble(), 1);
    minY = max(0, minY - verticalInterval);
    maxY = maxY + verticalInterval;

    if (goalSublist.isEmpty) {
      return Center(
        child: Text("No entries this " + ['week', 'month', 'year'][index]),
      );
    }
    return Container(
      padding: EdgeInsets.only(
        right: 36.0,
        left: 14.0,
        top: 14.0,
        bottom: 14.0,
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          minX: minX,
          maxX: maxX,
          borderData: FlBorderData(
            border: Border.all(color: Colors.white),
          ),
          backgroundColor: Colors.black.withOpacity(0.7),
          gridData: FlGridData(
            horizontalInterval: verticalInterval,
            verticalInterval: horizontalInterval,
            drawVerticalLine: true,
          ),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
          ),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              getTextStyles: (_) => Theme.of(context).textTheme.bodyText1,
              getTitles: (n) => '${n.floor()}',
              interval: verticalInterval,
              showTitles: true,
            ),
            bottomTitles: SideTitles(
              getTextStyles: (_) => Theme.of(context).textTheme.bodyText1,
              getTitles: getXTitles,
              interval: horizontalInterval,
              showTitles: true,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              colors: [Colors.blue],
              belowBarData: BarAreaData(
                colors: [Colors.blue, Colors.transparent],
                gradientFrom: Offset(0, 0),
                gradientTo: Offset(0.0, 10.0),
                show: true,
              ),
              isCurved: false,
              preventCurveOverShooting: true,
              dotData: FlDotData(show: spots.length == 1),
              spots: spots,
            )
          ],
        ),
      ),
    );
  }

  _getSelectedGoalEntries() {
    this.goalEntries = userBloc.userData.goalEntries.where((entry) {
      return entry.goalId == selectedGoal?.id;
    }).toList();
    this.goalEntries.sort((a, b) => a.id.compareTo(b.id));
  }
}
