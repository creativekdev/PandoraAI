import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../gallery_saver.dart';

class ShareScreen extends StatefulWidget {
  final String image;
  final bool isVideo;
  const ShareScreen({Key? key, required this.image, required this.isVideo}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => {Navigator.pop(context)},
                    child: Image.asset(
                      ImagesConstant.ic_back_dark,
                      height: 10.w,
                      width: 10.w,
                    ),
                  ),
                  TitleTextWidget(StringConstant.save_share, ColorConstant.BtnTextColor, FontWeight.w600, 14.sp),
                  GestureDetector(
                    onTap: () => {Navigator.of(context).popUntil(ModalRoute.withName("/HomeScreen"))},
                    child: Image.asset(
                      ImagesConstant.ic_home,
                      height: 10.w,
                      width: 10.w,
                    ),
                  ),
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
                                File decodedimgfile;
                                String dir = (await getApplicationDocumentsDirectory()).path;
                                String fullPath = '$dir/abc.png';

                                if (widget.isVideo) {
                                  decodedimgfile = File(widget.image);
                                  try {
                                    await platform.invokeMethod('ShareFacebook', {'path': decodedimgfile.path});
                                  } on PlatformException catch (e) {
                                    print(e.message);
                                  }
                                } else {
                                  decodedimgfile = await File(fullPath).writeAsBytes(base64Decode(widget.image), flush: true);
                                  if (Platform.isIOS) {
                                    SocialShare.shareFacebookStory(decodedimgfile.path, "#ffffff", "#000000", "https://deep-link-url");
                                  } else {
                                    SocialShare.shareFacebookStory(decodedimgfile.path, "#ffffff", "#000000", "https://deep-link-url", appId: "801412163654865");
                                  }
                                }
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
                                String dir = (await getApplicationDocumentsDirectory()).path;
                                String fullPath = '$dir/abc.png';
                                File decodedimgfile;
                                if (widget.isVideo) {
                                  decodedimgfile = File(widget.image);
                                  try {
                                    await platform.invokeMethod('ShareInsta', {'path': decodedimgfile.path});
                                  } on PlatformException catch (e) {
                                    print(e.message);
                                  }
                                } else {
                                  decodedimgfile = await File(fullPath).writeAsBytes(base64Decode(widget.image), flush: true);
                                  SocialShare.shareInstagramStory(decodedimgfile.path,
                                      backgroundTopColor: "#FFFFFF", backgroundBottomColor: "#FFFFFF", attributionURL: "https://deep-link-url");
                                }
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
                                final FlutterShareMe flutterShareMe = FlutterShareMe();
                                String dir = (await getApplicationDocumentsDirectory()).path;
                                String fullPath = '$dir/abc.png';
                                File decodedimgfile;
                                if (widget.isVideo) {
                                  decodedimgfile = File(widget.image);
                                } else {
                                  decodedimgfile = await File(fullPath).writeAsBytes(base64Decode(widget.image), flush: true);
                                }
                                await flutterShareMe.shareToWhatsApp(imagePath: decodedimgfile.path, fileType: (widget.isVideo) ? FileType.video : FileType.image);
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
                              String dir = (await getApplicationDocumentsDirectory()).path;
                              String fullPath = '$dir/abc.png';
                              File decodedimgfile;
                              if (widget.isVideo) {
                                decodedimgfile = File(widget.image);
                              } else {
                                decodedimgfile = await File(fullPath).writeAsBytes(base64Decode(widget.image), flush: true);
                              }
                              List<String> paths = [decodedimgfile.path];
                              final Email email = Email(
                                body: '',
                                subject: '',
                                recipients: [''],
                                attachmentPaths: paths,
                              );
                              await FlutterEmailSender.send(email);
                            },
                            child: Image.asset(
                              ImagesConstant.ic_share_email,
                              height: 14.w,
                              width: 14.w,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final box = context.findRenderObject() as RenderBox?;
                              String dir = (await getApplicationDocumentsDirectory()).path;
                              String fullPath = '$dir/abc.png';
                              File decodedimgfile;
                              if (widget.isVideo) {
                                decodedimgfile = File(widget.image);
                              } else {
                                decodedimgfile = await File(fullPath).writeAsBytes(base64Decode(widget.image), flush: true);
                              }
                              List<String> paths = [decodedimgfile.path];
                              await Share.shareFiles(paths, sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
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
