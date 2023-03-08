import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:path_provider/path_provider.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:share_plus/share_plus.dart';

enum ShareType {
  discovery,
  facebook,
  instagram,
  whatsapp,
  twitter,
  email,
  system,
}

extension ShareTypeEx on ShareType {
  String imageRes() {
    switch (this) {
      case ShareType.discovery:
        return Images.ic_share_discovery;
      case ShareType.facebook:
        return Images.ic_share_facebook;
      case ShareType.instagram:
        return Images.ic_share_instagram;
      case ShareType.whatsapp:
        return Images.ic_share_whatsapp;
      case ShareType.email:
        return Images.ic_share_email;
      case ShareType.system:
        return Images.ic_share_more;
      case ShareType.twitter:
        return Images.ic_share_twitter;
    }
  }

  String title({required BuildContext context}) {
    switch (this) {
      case ShareType.discovery:
        return S.of(context).tabDiscovery;
      case ShareType.facebook:
        return 'Facebook';
      case ShareType.instagram:
        return 'Instagram';
      case ShareType.whatsapp:
        return 'Whatsapp';
      case ShareType.email:
        return 'Email';
      case ShareType.twitter:
        return 'Twitter';
      case ShareType.system:
        return S.of(context).more;
    }
  }

  String value() {
    switch (this) {
      case ShareType.discovery:
        return 'Discovery';
      case ShareType.facebook:
        return 'Facebook';
      case ShareType.instagram:
        return 'Instagram';
      case ShareType.whatsapp:
        return 'Whatsapp';
      case ShareType.email:
        return 'Email';
      case ShareType.twitter:
        return 'Twitter';
      case ShareType.system:
        return 'System';
    }
  }
}

class ShareScreen extends StatefulWidget {
  static Future<bool?> startShare(
    BuildContext context, {
    Color backgroundColor = Colors.transparent,
    required String style,
    required String image,
    required bool isVideo,
    required String? originalUrl,
    required String effectKey,
    bool needDiscovery = false,
    Function(String platform)? onShareSuccess,
  }) {
    return showModalBottomSheet<bool>(
        context: context,
        builder: (context) {
          return ShareScreen(
            style: style,
            image: image,
            isVideo: isVideo,
            originalUrl: originalUrl,
            backgroundColor: backgroundColor,
            effectKey: effectKey,
            needDiscovery: needDiscovery,
          );
        },
        backgroundColor: backgroundColor);
  }

  final Function(String platform)? onShareSuccess;
  final String style;
  final String image;
  final bool isVideo;
  final String? originalUrl;
  final Color backgroundColor;
  final String effectKey;
  final bool needDiscovery;

  const ShareScreen({
    Key? key,
    required this.style,
    required this.image,
    required this.isVideo,
    required this.originalUrl,
    required this.backgroundColor,
    required this.effectKey,
    this.onShareSuccess,
    required this.needDiscovery,
  }) : super(key: key);

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  static const platform = MethodChannel(PLATFORM_CHANNEL);
  Size? cancelSize;

  List<ShareType> typeList = [
    // ShareType.discovery,
    // ShareType.facebook,
    ShareType.instagram,
    ShareType.whatsapp,
    ShareType.email,
    ShareType.system,
  ];

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'share_screen');
    if (widget.needDiscovery) {
      typeList.insert(0, ShareType.discovery);
    }
  }

  void _openShareAction(BuildContext context, List<String> paths) {
    final box = context.findRenderObject() as RenderBox?;
    Share.shareXFiles(paths.map((e) => XFile(e)).toList(), sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
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
      case ShareType.twitter:
        onShareButtonTap(shareType: shareType);
        break;
      case ShareType.discovery:
      case ShareType.email:
      case ShareType.system:
        onShareButtonTap(shareType: shareType);
        break;
    }
  }

  Future<void> onShareButtonTap({required ShareType shareType}) async {
    File file;
    var dir = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
    String fullPath = '$dir${DateTime.now().millisecondsSinceEpoch}.png';

    if (widget.isVideo) {
      file = File(widget.image);
    } else {
      file = await File(fullPath).writeAsBytes(base64Decode(widget.image), flush: true);
    }

    final FlutterShareMe flutterShareMe = FlutterShareMe();

    switch (shareType) {
      case ShareType.discovery:
        AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction:'share_discovery_from_ai_avatar',callback: () {
          ShareDiscoveryScreen.push(
            context,
            effectKey: widget.effectKey,
            originalUrl: widget.originalUrl,
            image: widget.image,
            isVideo: widget.isVideo,
            category: DiscoveryCategory.ai_avatar,
          ).then((value) {
            if (value ?? false) {
              widget.onShareSuccess?.call(shareType.value());
              Navigator.of(context).pop(true);
            }
          });
        });
        break;
      case ShareType.facebook:
        // if (widget.isVideo) {
        //   _openShareAction(context, [file.path]);
        // } else {
        //   if (Platform.isAndroid) {
        //     // _openShareAction(context, [file.path]);
        //     // await flutterShareMe.shareToFacebook(msg: "AAAAAAAAAAAAAAAA");
        //     await platform.invokeMethod('ShareFacebook', {'fileURL': file.path, 'fileType': widget.isVideo ? 'video' : 'image'});
        //   } else {
        //     await platform.invokeMethod('ShareFacebook', {'fileURL': file.path, 'fileType': widget.isVideo ? 'video' : 'image'});
        //   }
        // }
        _openShareAction(context, [file.path]);
        widget.onShareSuccess?.call(shareType.value());
        Navigator.of(context).pop();
        break;
      case ShareType.instagram:
        await flutterShareMe.shareToInstagram(filePath: file.path, fileType: widget.isVideo ? FileType.video : FileType.image);
        widget.onShareSuccess?.call(shareType.value());
        Navigator.of(context).pop();
        break;
      case ShareType.whatsapp:
        await flutterShareMe.shareToWhatsApp(msg: S.of(context).share_title, imagePath: file.path, fileType: widget.isVideo ? FileType.video : FileType.image);
        widget.onShareSuccess?.call(shareType.value());
        Navigator.of(context).pop();
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
        widget.onShareSuccess?.call(shareType.value());
        Navigator.of(context).pop();
        break;
      case ShareType.system:
        widget.onShareSuccess?.call(shareType.value());
        _openShareAction(context, [file.path]);
        break;
      case ShareType.twitter:
        widget.onShareSuccess?.call(shareType.value());
        Navigator.of(context).pop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            SizedBox(width: cancelSize?.width ?? 50),
            Expanded(child: TitleTextWidget(S.of(context).share, ColorConstant.White, FontWeight.w600, $(17), align: TextAlign.center)),
            TitleTextWidget(S.of(context).cancel, ColorConstant.White, FontWeight.normal, $(15))
                .intoContainer(padding: EdgeInsets.symmetric(horizontal: $(8), vertical: $(8)))
                .intoGestureDetector(onTap: () {
              Navigator.of(context).pop();
            }).listenSizeChanged(onSizeChanged: (size) {
              setState(() => cancelSize = size);
            })
          ],
        ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(8))),
        Container(
          height: 0.5,
          color: ColorConstant.EffectGrey,
          margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(10)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: typeList.map((e) => _FunctionCard(type: e, onTap: () => onShareClick(e))).toList(),
          ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(30), horizontal: $(6))),
        ),
      ],
    ).intoContainer(
        padding: EdgeInsets.symmetric(vertical: $(15)),
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
