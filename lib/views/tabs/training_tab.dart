import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/exercise_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/program.dart';
import 'package:jdarwish_dashboard_web/shared/models/training_day.dart';
import 'package:jdarwish_dashboard_web/shared/navigate_helpers.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/circle_item.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/circle_switcher.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/photo_tile.dart';
import 'package:jdarwish_dashboard_web/views/tabs/training_day_view.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

class TrainingTab extends StatefulWidget {
  @override
  _TrainingTabState createState() => _TrainingTabState();
}

class _TrainingTabState extends State<TrainingTab> {
  Program selectedProgram;
  List<Program> programs;

  @override
  void initState() {
    super.initState();

    programs = ExerciseBloc().exercisePrograms;
    selectedProgram = programs.isNotEmpty ? programs[0] : null;
  }

  @override
  Widget build(BuildContext context) {
    if (programs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.dumbbell,
              size: 32.0,
            ),
            SizedBox(height: 20),
            Container(
              width: 240.0,
              child: Text(
                "Check back soon for exercise plans.",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    programs.sort((a, b) {
      return a.order.compareTo(b.order);
    });
    return Stack(
      children: [
        Column(
          children: [
            CircleSwitcher(
              items: [
                for (Program program in programs)
                  CircleItem(
                    title: program.name,
                    color: program.themeColor,
                    outlineColor: Colors.white,
                    onTap: () {
                      setState(() => this.selectedProgram = program);
                      print(program.id);
                    },
                    selected: this.selectedProgram.id == program.id,
                  )
              ],
            ),
            Divider(height: 2.0, thickness: 2.0),
            if (programs.length != 0)
              Expanded(
                child: _daysList(selectedProgram.trainingDays),
              ),
          ],
        ),
      ],
    );
  }

  Widget _daysList(List<TrainingDay> trainingDays) {
    trainingDays.sort((a, b) => a.order.compareTo(b.order));
    return Container(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
          itemCount: trainingDays.length,
          itemBuilder: ((context, i) {
            return PhotoTile(
              title: trainingDays[i].title,
              subtitle: trainingDays[i].subtitle ?? '',
              photoUrl: trainingDays[i].imageUrl,
              onTap: () => navigate(
                context,
                TrainingDayView(trainingDay: trainingDays[i]),
              ),
            );
          }),
        ),
      ),
    );
  }
}
