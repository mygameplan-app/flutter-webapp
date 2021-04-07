import 'package:flutter/material.dart';
import 'package:jdarwish_dashboard_web/shared/blocs/lifestyle_bloc.dart';
import 'package:jdarwish_dashboard_web/shared/navigate_helpers.dart';
import 'package:jdarwish_dashboard_web/shared/widgets/photo_tile.dart';
import 'package:jdarwish_dashboard_web/views/pages/custom_video_player.dart';

class LifestyleTab extends StatefulWidget {
  @override
  _LifestyleTabState createState() => _LifestyleTabState();
}

class _LifestyleTabState extends State<LifestyleTab> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: LifestyleBloc().lifestyleItems.length,
      itemBuilder: ((context, i) {
        return PhotoTile(
          title: LifestyleBloc().lifestyleItems[i].title ?? '',
          subtitle: LifestyleBloc().lifestyleItems[i].subtitle ?? '',
          photoUrl: LifestyleBloc().lifestyleItems[i].imageUrl,
          onTap: () => navigate(
            context,
            YoutubeVideoPlayer(
              videoUrl: LifestyleBloc().lifestyleItems[i].videoUrl,
            ),
          ),
          onPhotoTap: () => navigate(
            context,
            YoutubeVideoPlayer(
              videoUrl: LifestyleBloc().lifestyleItems[i].videoUrl,
            ),
          ),
        );
      }),
    );
  }
}
