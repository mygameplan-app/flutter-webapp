import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/nutrition_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_day.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_program.dart';
import 'package:jdarwish_dashboard_web/shared/navigate_helpers.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/circle_item.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/circle_switcher.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/photo_tile.dart';

import 'nutrition_day_view.dart';

class NutritionTab extends StatefulWidget {
  @override
  _NutritionTabState createState() => _NutritionTabState();
}

class _NutritionTabState extends State<NutritionTab> {
  NutritionProgram selectedProgram;
  List<NutritionProgram> programs;

  @override
  void initState() {
    programs = NutritionBloc().nutritionPrograms;
    selectedProgram = programs.isNotEmpty ? programs[0] : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (programs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 32.0,
            ),
            SizedBox(height: 20),
            Container(
              width: 240.0,
              child: Text(
                "Check back soon for nutrition plans.",
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
    return Column(
      children: [
        CircleSwitcher(
          items: [
            for (NutritionProgram program in programs)
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
            child: _daysList(selectedProgram.nutritionDays),
          ),
      ],
    );
  }

  Widget _daysList(List<NutritionDay> nutritionDays) {
    return Container(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
          itemCount: nutritionDays.length,
          itemBuilder: ((context, i) {
            return PhotoTile(
              title: nutritionDays[i].title,
              subtitle: nutritionDays[i].subtitle ?? '',
              photoUrl: nutritionDays[i].imageUrl,
              onTap: () => navigate(
                  context, NutritionDayView(nutritionDay: nutritionDays[i])),
            );
          }),
        ),
      ),
    );
  }
}
