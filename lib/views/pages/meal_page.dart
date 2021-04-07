import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/models/ingredient.dart';
import 'package:jdarwish_dashboard_web/shared/models/meal.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/photo_tile.dart';

class MealPage extends StatefulWidget {
  final Meal meal;

  MealPage({this.meal});

  @override
  _MealPageState createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
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
                  text: widget.meal.title.toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                  children: <TextSpan>[
                    TextSpan(
                      text: '\n${widget.meal.subtitle}',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
              ),
              background: Image.network(
                widget.meal.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 10, top: 10),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Directions',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(widget.meal.description),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15.0, bottom: 8),
                          child: Text(
                            'Ingredients'.toUpperCase(),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                for (Ingredient ingredient in widget.meal.ingredients)
                  Column(
                    children: [
                      widget.meal.ingredients.indexOf(ingredient) == 0
                          ? Divider(
                              indent: 5,
                              color: Colors.grey,
                              height: 1,
                              thickness: 1,
                            )
                          : Container(),
                      PhotoTile(
                          title: ingredient.title,
                          subtitle: '',
                          photoUrl: ingredient.imageUrl,
                          onTap: () {}),
                      Divider(
                        indent: 5,
                        color: Colors.grey,
                        height: 1,
                        thickness: 1,
                      )
                    ],
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
