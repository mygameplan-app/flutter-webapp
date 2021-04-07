import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle.dart';
import 'package:jdarwish_dashboard_web/shared/models/lifestyle_day.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/photo_tile.dart';

class LifestyleDayView extends StatefulWidget {
  final LifestyleDay lifestyleDay;

  LifestyleDayView({
    this.lifestyleDay,
  });

  @override
  _LifestyleDayViewState createState() => _LifestyleDayViewState();
}

class _LifestyleDayViewState extends State<LifestyleDayView> {
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
                  text: widget.lifestyleDay.title.toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                  children: <TextSpan>[
                    TextSpan(
                      text: '\n${widget.lifestyleDay.subtitle}',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
              ),
              background: Image.network(
                widget.lifestyleDay.imageUrl,
                color: Colors.black.withOpacity(0.2),
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                for (LifestyleItem lifestyleItem in widget.lifestyleDay.items)
                  PhotoTile(
                    title: lifestyleItem.title,
                    subtitle: lifestyleItem.subtitle ?? '',
                    photoUrl: lifestyleItem.imageUrl,
                    // onTap: () => navigate(
                    //   context,
                    //   LifestyleItemPage(lifestyleItem: lifestyleItem),
                    // ),
                    onTap: () => Get.toNamed(
                      '/exercisevideo',
                      arguments: lifestyleItem.videoUrl,
                    ),
                    onPhotoTap: () => Get.toNamed(
                      '/exercisevideo',
                      arguments: lifestyleItem.videoUrl,
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
