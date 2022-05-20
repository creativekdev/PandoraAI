import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_share_me/flutter_share_me.dart';

enum ShareType {
  facebook,
  instagram,
  whatsapp,
  email,
  system,
}

class ShareScreen extends StatefulWidget {
  final String style;
  final String image;
  final bool isVideo;
  const ShareScreen({Key? key, required this.style, required this.image, required this.isVideo}) : super(key: key);

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  static const platform = MethodChannel('io.socialbook/cartoonizer');
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      print(widget.image);
      _videoPlayerController = VideoPlayerController.file(File(widget.image))
        ..setLooping(true)
        ..initialize().then((value) async {
          setState(() {});
          // controller.changeIsLoading(false);
        });
      _videoPlayerController.play();
    }
  }

  void _openShareAction(BuildContext context, List<String> paths) {
    final box = context.findRenderObject() as RenderBox?;
    Share.shareFiles(paths, sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size, text: StringConstant.share_title);
  }

  Future<void> onShareButtonTap({required ShareType shareType, BuildContext? context}) async {
    File file;
    String dir = (await getApplicationDocumentsDirectory()).path;
    String fullPath = '$dir/${DateTime.now().millisecondsSinceEpoch}.jpeg';

    if (widget.isVideo) {
      file = File(widget.image);
    } else {
      file = await File(fullPath).writeAsBytes(base64Decode(widget.image), flush: true);
    }

    final FlutterShareMe flutterShareMe = FlutterShareMe();

    FirebaseAnalytics.instance.logEvent(name: Events.result_share, parameters: {
      "style": widget.style,
      "method": shareType.name,
    });

    switch (shareType) {
      case ShareType.facebook:
        if (widget.isVideo) {
          _openShareAction(context!, [file.path]);
        } else {
          if (Platform.isAndroid) {
            _openShareAction(context!, [file.path]);
            // await flutterShareMe.shareToFacebook(msg: "AAAAAAAAAAAAAAAA");
            // await platform.invokeMethod('ShareFacebook', {'fileURL': file.path, 'fileType': widget.isVideo ? 'video' : 'image'});
          } else {
            await platform.invokeMethod('ShareFacebook', {'fileURL': file.path, 'fileType': widget.isVideo ? 'video' : 'image'});
          }
        }
        break;
      case ShareType.instagram:
        await flutterShareMe.shareToInstagram(filePath: file.path, fileType: widget.isVideo ? FileType.video : FileType.image);
        break;
      case ShareType.whatsapp:
        await flutterShareMe.shareToWhatsApp(msg: StringConstant.share_title, imagePath: file.path, fileType: widget.isVideo ? FileType.video : FileType.image);
        break;
      case ShareType.email:
        List<String> paths = [file.path];
        final Email email = Email(
          body: '',
          subject: '',
          recipients: [''],
          attachmentPaths: paths,
        );
        await FlutterEmailSender.send(email);
        break;
      case ShareType.system:
        _openShareAction(context!, [file.path]);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeConstants.TopBarEdgeInsets,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => {Navigator.pop(context)},
                    child: Image.asset(ImagesConstant.ic_back, height: 30, width: 30),
                  ),
                  TitleTextWidget(StringConstant.save_share, ColorConstant.BtnTextColor, FontWeight.w600, FontSizeConstants.topBarTitle),
                  SizedBox(width: 30, height: 30)
                  //   GestureDetector(
                  //     onTap: () => {Navigator.of(context).popUntil(ModalRoute.withName("/HomeScreen"))},
                  //     child: Image.asset(
                  //       ImagesConstant.ic_home,
                  //       height: 10.w,
                  //       width: 10.w,
                  //     ),
                  //   ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5.w),
                      child: (widget.isVideo)
                          ? AspectRatio(
                              aspectRatio: _videoPlayerController.value.aspectRatio,
                              child: VideoPlayer(_videoPlayerController),
                            )
                          : Image.memory(
                              base64Decode(widget.image),
                              width: 90.w,
                              height: 90.w,
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              color: ColorConstant.DividerColor,
                              thickness: 0.1.h,
                            ),
                          ),
                          SizedBox(
                            width: 3.w,
                          ),
                          TitleTextWidget(StringConstant.share_to, ColorConstant.BtnTextColor, FontWeight.w500, 12.sp),
                          SizedBox(
                            width: 3.w,
                          ),
                          Expanded(
                            child: Divider(
                              color: ColorConstant.DividerColor,
                              thickness: 0.1.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              var isAppInstalled = (Platform.isAndroid)
                                  ? await platform.invokeMethod("AppInstall", {'path': "com.facebook.katana"})
                                  : await platform.invokeMethod("AppInstall", {'path': "fbapi"});
                              if (!isAppInstalled) {
                                CommonExtension().showToast("Facebook is not installed on this device");
                              } else {
                                onShareButtonTap(shareType: ShareType.facebook, context: context);
                              }
                            },
                            child: Image.asset(
                              ImagesConstant.ic_share_facebook,
                              height: 14.w,
                              width: 14.w,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              var isAppInstalled = (Platform.isAndroid)
                                  ? await platform.invokeMethod("AppInstall", {'path': "com.instagram.android"})
                                  : await platform.invokeMethod("AppInstall", {'path': "Instagram"});
                              if (!isAppInstalled) {
                                CommonExtension().showToast("Instagram is not installed on this device");
                              } else {
                                onShareButtonTap(shareType: ShareType.instagram);
                              }
                            },
                            child: Image.asset(
                              ImagesConstant.ic_share_instagram,
                              height: 14.w,
                              width: 14.w,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              var isAppInstalled = (Platform.isAndroid)
                                  ? await platform.invokeMethod("AppInstall", {'path': "com.whatsapp"})
                                  : await platform.invokeMethod("AppInstall", {'path': "Whatsapp"});
                              if (!isAppInstalled) {
                                CommonExtension().showToast("Whatsapp is not installed on this device");
                              } else {
                                onShareButtonTap(shareType: ShareType.whatsapp);
                              }
                            },
                            child: Image.asset(
                              ImagesConstant.ic_share_whatsapp,
                              height: 14.w,
                              width: 14.w,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              onShareButtonTap(shareType: ShareType.email);
                            },
                            child: Image.asset(
                              ImagesConstant.ic_share_email,
                              height: 14.w,
                              width: 14.w,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              onShareButtonTap(shareType: ShareType.system, context: context);
                            },
                            child: Image.asset(
                              ImagesConstant.ic_share_more,
                              height: 14.w,
                              width: 14.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
