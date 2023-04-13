import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class ShareUrlScreen extends StatefulWidget {
  static Future<String?> startShare(
    BuildContext context, {
    Color backgroundColor = Colors.transparent,
    required String url,
  }) {
    return showModalBottomSheet<String>(
        context: context,
        builder: (context) {
          return ShareUrlScreen(
            url: url,
            backgroundColor: backgroundColor,
          );
        },
        backgroundColor: backgroundColor);
  }

  final Color backgroundColor;
  final String url;

  const ShareUrlScreen({
    Key? key,
    required this.url,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareUrlScreen> {
  static const platform = MethodChannel(PLATFORM_CHANNEL);
  Size? cancelSize;

  List<ShareType> typeList = [
    ShareType.facebook,
    // ShareType.instagram,
    ShareType.whatsapp,
    ShareType.twitter,
    ShareType.email,
    ShareType.system,
  ];

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'share_screen');
  }

  void _openShareAction(BuildContext context, String url) async {
    await FlutterShareMe().shareToSystem(msg: url);
    Navigator.of(context).pop(ShareType.system.value());
  }

  onShareClick(ShareType shareType) async {
    switch (shareType) {
      case ShareType.facebook:
        var isAppInstalled =
            (Platform.isAndroid) ? await platform.invokeMethod("AppInstall", {'path': "com.facebook.katana"}) : await platform.invokeMethod("AppInstall", {'path': "fbapi"});
        if (!isAppInstalled) {
          CommonExtension().showToast("Facebook is not installed on this device");
        } else {
          onShareButtonTap(shareType: shareType);
        }
        break;
      case ShareType.twitter:
        onShareButtonTap(shareType: shareType);
        break;
      case ShareType.instagram:
        var isAppInstalled =
            (Platform.isAndroid) ? await platform.invokeMethod("AppInstall", {'path': "com.instagram.android"}) : await platform.invokeMethod("AppInstall", {'path': "Instagram"});
        if (!isAppInstalled) {
          CommonExtension().showToast("Instagram is not installed on this device");
        } else {
          onShareButtonTap(shareType: shareType);
        }
        break;
      case ShareType.whatsapp:
        var isAppInstalled =
            (Platform.isAndroid) ? await platform.invokeMethod("AppInstall", {'path': "com.whatsapp"}) : await platform.invokeMethod("AppInstall", {'path': "Whatsapp"});
        if (!isAppInstalled) {
          CommonExtension().showToast("Whatsapp is not installed on this device");
        } else {
          onShareButtonTap(shareType: shareType);
        }
        break;
      case ShareType.discovery:
        LogUtil.e('wrong share type');
        break;
      case ShareType.email:
      case ShareType.system:
        onShareButtonTap(shareType: shareType);
        break;
    }
  }

  Future<void> onShareButtonTap({required ShareType shareType}) async {
    final FlutterShareMe flutterShareMe = FlutterShareMe();

    switch (shareType) {
      case ShareType.facebook:
        await flutterShareMe.shareToFacebook(msg: '', url: widget.url);
        Navigator.of(context).pop(shareType.value());
        break;
      // case ShareType.instagram:
      //   await flutterShareMe.shareToInstagram(filePath: widget.url, fileType: FileType.image);
      //   Navigator.of(context).pop();
      //   break;
      // case ShareType.whatsapp:
      // await flutterShareMe.shareToWhatsApp(msg: S.of(context).share_title, imagePath: file.path, fileType: widget.isVideo ? FileType.video : FileType.image);
      // Navigator.of(context).pop();
      // break;
      case ShareType.email:
        final Email email = Email(
          body: widget.url,
          subject: '',
          recipients: [''],
        );
        await FlutterEmailSender.send(email);
        Navigator.of(context).pop(shareType.value());
        break;
      case ShareType.twitter:
        await flutterShareMe.shareToTwitter(msg: '', url: widget.url);
        Navigator.of(context).pop(shareType.value());
        break;
      case ShareType.system:
        await flutterShareMe.shareToSystem(msg: widget.url);
        Navigator.of(context).pop(shareType.value());
        break;
      case ShareType.whatsapp:
        flutterShareMe.shareToWhatsApp(msg: widget.url);
        Navigator.of(context).pop(shareType.value());
        break;
      default:
        _openShareAction(context, widget.url);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleTextWidget(S.of(context).share, ColorConstant.White, FontWeight.w600, $(17), align: TextAlign.start).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: typeList.map((e) => _FunctionCard(type: e, onTap: () => onShareClick(e))).toList(),
          ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(30), horizontal: $(6))),
        ),
        Divider(height: 1, color: ColorConstant.LineColor),
        TitleTextWidget(S.of(context).cancel, ColorConstant.White, FontWeight.normal, $(15))
            .intoContainer(padding: EdgeInsets.symmetric(horizontal: $(8), vertical: $(15)))
            .intoGestureDetector(onTap: () {
              Navigator.of(context).pop();
            })
            .intoContainer(width: double.maxFinite, alignment: Alignment.center)
            .listenSizeChanged(onSizeChanged: (size) {
              setState(() => cancelSize = size);
            })
      ],
    ).intoContainer(
        padding: EdgeInsets.only(top: $(15), bottom: ScreenUtil.getBottomPadding(context) + $(10)),
        decoration: BoxDecoration(
            color: ColorConstant.EffectFunctionGrey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular($(24)),
              topRight: Radius.circular($(24)),
            )));
  }
}

class _FunctionCard extends StatelessWidget {
  ShareType type;
  GestureTapCallback? onTap;

  _FunctionCard({Key? key, required this.type, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        type == ShareType.discovery
            ? Container(
                width: $(50),
                height: $(50),
                padding: EdgeInsets.all($(6)),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular($(64)),
                    gradient: LinearGradient(
                      colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )),
                child: Image.asset(type.imageRes()),
              )
            : Image.asset(type.imageRes(), width: $(50), height: $(50)),
        SizedBox(height: $(6)),
        TitleTextWidget(type.title(context: context), ColorConstant.White, FontWeight.normal, $(12)),
      ],
    ).intoContainer(constraints: BoxConstraints(minWidth: ScreenUtil.screenSize.width / 4.65)).intoGestureDetector(onTap: onTap);
  }
}
