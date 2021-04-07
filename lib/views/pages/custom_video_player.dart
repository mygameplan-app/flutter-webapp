import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeVideoPlayer extends StatefulWidget {
  String videoUrl;

  YoutubeVideoPlayer({
    this.videoUrl,
  });

  @override
  _YoutubeVideoPlayerState createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> {
  YoutubePlayerController controller;
  String getId() {
    if (widget.videoUrl != null) {
      return YoutubePlayerController.convertUrlToId(widget.videoUrl);
    }
    return YoutubePlayerController.convertUrlToId(Get.arguments);
  }

  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController(
      initialVideoId: getId(),
      params: const YoutubePlayerParams(
        startAt: const Duration(minutes: 0, seconds: 0),
        showControls: false,
        showFullscreenButton: false,
        desktopMode: false,
        privacyEnhanced: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.arguments;

    return Material(
      child: Column(
        children: [
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.navigate_before,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Spacer(
                  flex: 1,
                )
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 40,
            width: MediaQuery.of(context).size.width,
            child: YoutubePlayerIFrame(
              aspectRatio: MediaQuery.of(context).size.height -
                  40 / MediaQuery.of(context).size.width,
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.drain();
  }
}
