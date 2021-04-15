import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdarwish_dashboard_web/shared/models/exercise.dart';
import 'package:jdarwish_dashboard_web/shared/models/training_day.dart';
import 'package:jdarwish_dashboard_web/shared/navigate_helpers.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/photo_tile.dart';
import 'package:jdarwish_dashboard_web/views/pages/exercise_page.dart';

class TrainingDayView extends StatefulWidget {
  final TrainingDay trainingDay;

  TrainingDayView({
    this.trainingDay,
  });

  @override
  _TrainingDayViewState createState() => _TrainingDayViewState();
}

class _TrainingDayViewState extends State<TrainingDayView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  text: widget.trainingDay.title.toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                  children: <TextSpan>[
                    TextSpan(
                      text: '\n${widget.trainingDay.subtitle}',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
              ),
              background: Image.network(
                widget.trainingDay.imageUrl,
                color: Colors.black.withOpacity(0.2),
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                for (Exercise exercise in widget.trainingDay.exercises)
                  PhotoTile(
                    title: exercise.title,
                    subtitle: exercise.description ?? '',
                    photoUrl: exercise.imageUrl,
                    onPhotoTap: ((exercise.videoUrl ?? "") != "")
                        ? () => Get.toNamed('/exercisevideo',
                            arguments: exercise.videoUrl)
                        : null,
                    onTap: () => navigate(
                      context,
                      ExercisePage(exercise: exercise),
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
