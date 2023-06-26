import 'dart:io';

import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/image/sync_download_video.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class ViewPreviewScreen extends StatefulWidget {
  String url;
  String title;

  ViewPreviewScreen({super.key, required this.url, required this.title});

  @override
  State<ViewPreviewScreen> createState() => _ViewPreviewScreenState();
}

class _ViewPreviewScreenState extends State<ViewPreviewScreen> {
  File? videoFile;

  bool onCompleted = false;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'video_preview_screen', eventValues: {'title': widget.title});
    SyncDownloadVideo(url: widget.url, type: getFileType(widget.url)).getVideo().then((value) {
      setState(() {
        videoFile = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(widget.title, Colors.white, FontWeight.w500, $(17)),
      ),
      body: Stack(
        children: [
          if (videoFile != null)
            EffectVideoPlayer(
              url: videoFile!.path,
              isFile: true,
              loop: false,
              onCompleted: () {
                if (mounted) {
                  delay(() {
                    setState(() {
                      onCompleted = true;
                    });
                  });
                }
              },
            ).intoContainer(width: ScreenUtil.screenSize.width).intoCenter().intoContainer(margin: EdgeInsets.only(bottom: $(80))),
          Positioned(
            child: TitleTextWidget('Start Now', Colors.white, FontWeight.normal, $(16))
                .intoContainer(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: $(12)),
              decoration: BoxDecoration(color: ColorConstant.DiscoveryBtn, borderRadius: BorderRadius.circular($(32))),
            )
                .intoGestureDetector(onTap: () {
              Navigator.of(context).pop(true);
            }),
            left: $(25),
            right: $(25),
            bottom: ScreenUtil.getBottomPadding(context),
          ),
        ],
      ),
    );
  }
}
