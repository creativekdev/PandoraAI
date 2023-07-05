import 'dart:io';

import 'package:cartoonizer/Widgets/image/sync_download_video.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/main.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class ViewPreviewScreen extends StatefulWidget {
  String url;
  String title;
  String description;

  ViewPreviewScreen({
    super.key,
    required this.url,
    required this.title,
    required this.description,
  });

  @override
  State<ViewPreviewScreen> createState() => _ViewPreviewScreenState();
}

class _ViewPreviewScreenState extends State<ViewPreviewScreen> {
  File? videoFile;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'video_preview_screen', eventValues: {'title': widget.title});
    SyncDownloadVideo(url: widget.url, type: getFileType(widget.url)).getVideo().then((value) {
      if (mounted) {
        setState(() {
          videoFile = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (videoFile != null)
            EffectVideoPlayer(
              url: videoFile!.path,
              isFile: true,
              loop: false,
              onCompleted: () {
                if (mounted) {
                  if (MyApp.routeObserver.currentRoute?.settings.name == '/ViewPreviewScreen') {
                    Navigator.of(context).pop(true);
                  }
                }
              },
            ).intoContainer(width: ScreenUtil.screenSize.width).intoCenter(),
          Positioned(
            child: Container(
              width: ScreenUtil.screenSize.width,
              height: ScreenUtil.getStatusBarHeight(),
              color: Color(0x44000000),
            ),
            top: 0,
            left: 0,
            right: 0,
          ),
          Positioned(
            child: Icon(
              Icons.close,
              size: $(24),
              color: Colors.white,
            )
                .intoContainer(
                    padding: EdgeInsets.all($(8)),
                    margin: EdgeInsets.all($(7)),
                    decoration: BoxDecoration(
                      color: Color(0x44000000),
                      borderRadius: BorderRadius.circular($(32)),
                    ))
                .intoGestureDetector(onTap: () {
              if (MyApp.routeObserver.currentRoute?.settings.name == '/ViewPreviewScreen') {
                Navigator.of(context).pop(true);
              }
            }),
            top: ScreenUtil.getStatusBarHeight(),
            right: $(7),
          ),
          Positioned(
            child: Column(
              children: [
                Container(
                  height: $(50),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x00000000),
                        Color(0x99000000),
                        Color(0xff000000),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                TitleTextWidget(widget.description, ColorConstant.White, FontWeight.w500, $(20), maxLines: 10)
                    .intoContainer(color: Colors.black, padding: EdgeInsets.symmetric(horizontal: $(25), vertical: $(10))),
                TitleTextWidget(S.of(context).start_now, Colors.white, FontWeight.normal, $(16))
                    .intoContainer(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: $(12)),
                  decoration: BoxDecoration(color: ColorConstant.DiscoveryBtn, borderRadius: BorderRadius.circular($(32))),
                )
                    .intoGestureDetector(onTap: () {
                  if (MyApp.routeObserver.currentRoute?.settings.name == '/ViewPreviewScreen') {
                    Navigator.of(context).pop(true);
                  }
                }).intoContainer(color: Colors.black, padding: EdgeInsets.symmetric(horizontal: $(25), vertical: $(15))),
                SizedBox(height: ScreenUtil.getBottomPadding(context)),
              ],
            ),
            left: $(0),
            right: $(0),
            bottom: $(0),
          ),
        ],
      ),
    );
  }
}
