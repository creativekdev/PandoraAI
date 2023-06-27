import 'dart:io';

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
      body: Stack(
        children: [
          if (videoFile != null)
            EffectVideoPlayer(
              url: videoFile!.path,
              isFile: true,
              loop: false,
              onCompleted: () {
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              },
            ).intoContainer(width: ScreenUtil.screenSize.width).intoCenter(),
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
              Navigator.of(context).pop(true);
            }),
            top: ScreenUtil.getStatusBarHeight(),
            right: $(0),
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
                TitleTextWidget(S.of(context).start_now, Colors.white, FontWeight.normal, $(16))
                    .intoContainer(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: $(12)),
                  decoration: BoxDecoration(color: ColorConstant.DiscoveryBtn, borderRadius: BorderRadius.circular($(32))),
                )
                    .intoGestureDetector(onTap: () {
                  Navigator.of(context).pop(true);
                }),
              ],
            ),
            left: $(25),
            right: $(25),
            bottom: ScreenUtil.getBottomPadding(context),
          ),
        ],
      ),
    );
  }
}
