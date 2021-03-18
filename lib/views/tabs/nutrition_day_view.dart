import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/models/meal.dart';
import 'package:jdarwish_dashboard_web/shared/models/nutrition_day.dart';
import 'package:jdarwish_dashboard_web/shared/navigate_helpers.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/photo_tile.dart';
import 'package:jdarwish_dashboard_web/views/pages/meal_page.dart';

class NutritionDayView extends StatefulWidget {
  final NutritionDay nutritionDay;

  NutritionDayView({
    this.nutritionDay,
  });

  @override
  _NutritionDayViewState createState() => _NutritionDayViewState();
}

class _NutritionDayViewState extends State<NutritionDayView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            stretch: true,
            expandedHeight: 240,
            toolbarHeight: kToolbarHeight + 24,
            onStretchTrigger: () {
              return;
            },
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
//                  StretchMode.fadeTitle,
              ],
              centerTitle: true,
              title: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: widget.nutritionDay.title.toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                  children: <TextSpan>[
                    TextSpan(
                      text: '\n${widget.nutritionDay.subtitle}',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
              ),
              background: Image.network(
                widget.nutritionDay.imageUrl,
                color: Colors.black.withOpacity(0.2),
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                for (Meal meal in widget.nutritionDay.meals)
                  PhotoTile(
                    title: meal.title,
                    subtitle: meal.subtitle ?? '',
                    photoUrl: meal.imageUrl,
                    onTap: () => navigate(
                      context,
                      MealPage(meal: meal),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
