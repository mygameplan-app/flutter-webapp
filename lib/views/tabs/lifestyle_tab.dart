import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/lifestyle_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_day.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_program.dart';
import 'package:jdarwish_dashboard_web/shared/navigate_helpers.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/circle_item.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/circle_switcher.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/photo_tile.dart';

import 'lifestyle_day_view.dart';

class LifestyleTab extends StatefulWidget {
  @override
  _LifestyleTabState createState() => _LifestyleTabState();
}

class _LifestyleTabState extends State<LifestyleTab> {
  LifestyleProgram selectedProgram;
  List<LifestyleProgram> programs;

  @override
  void initState() {
    programs = LifestyleBloc().lifestylePrograms;
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
                "Check back soon for lifestyle plans.",
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
            for (LifestyleProgram program in programs)
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
            child: _daysList(selectedProgram.lifestyleDays),
          ),
      ],
    );
  }

  Widget _daysList(List<LifestyleDay> lifestyleDays) {
    if (lifestyleDays?.isNotEmpty ?? false) {
      List<LifestyleItem> items = lifestyleDays.first.items;
      return Container(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: ((context, i) {
              return PhotoTile(
                title: items[i].title,
                subtitle: items[i].subtitle ?? '',
                photoUrl: items[i].imageUrl,
                // onTap: () => navigate(
                //     context, NutritionDayView(nutritionDay: nutritionDays[i])),
                onPhotoTap: () => Get.toNamed(
                  '/exercisevideo',
                  arguments: items[i].videoUrl,
                ),
                onTap: () => Get.toNamed(
                  '/exercisevideo',
                  arguments: items[i].videoUrl,
                ),
              );
            }),
          ),
        ),
      );
    }
    return Container(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
          itemCount: lifestyleDays.length,
          itemBuilder: ((context, i) {
            return PhotoTile(
              title: lifestyleDays[i].title,
              subtitle: lifestyleDays[i].subtitle ?? '',
              photoUrl: lifestyleDays[i].imageUrl,
              onTap: () => navigate(
                  context, LifestyleDayView(lifestyleDay: lifestyleDays[i])),
            );
          }),
        ),
      ),
    );
  }
}
