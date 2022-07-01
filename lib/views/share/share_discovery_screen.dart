import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as path;

const int _maxInputLength = 512;

class ShareDiscoveryScreen extends StatefulWidget {
  static Future<bool?> push(
    BuildContext context, {
    required String originalUrl,
    required String image,
    required bool isVideo,
    required String effectKey,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ShareDiscoveryScreen(
          isVideo: isVideo,
          originalUrl: originalUrl,
          image: image,
          effectKey: effectKey,
        ),
        settings: RouteSettings(name: "/ShareDiscoveryScreen"),
      ),
    );
  }

  String originalUrl;
  String image;
  bool isVideo;
  String effectKey;

  ShareDiscoveryScreen({
    Key? key,
    required this.originalUrl,
    required this.image,
    required this.isVideo,
    required this.effectKey,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ShareDiscoveryState();
  }
}

class ShareDiscoveryState extends AppState<ShareDiscoveryScreen> {
  bool canSubmit = false;
  late bool isVideo;
  late String image;
  late String originalUrl;
  Uint8List? imageData;
  late TextEditingController textEditingController;
  late CartoonizerApi api;
  late String effectKey;

  @override
  void initState() {
    super.initState();
    api = CartoonizerApi().bindState(this);
    textEditingController = TextEditingController();
    isVideo = widget.isVideo;
    image = widget.image;
    originalUrl = widget.originalUrl;
    effectKey = widget.effectKey;
    if (!isVideo) {
      imageData = base64Decode(image);
    }
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    textEditingController.dispose();
  }

  submit() {
    var text = textEditingController.text.trim();
    if (text.isEmpty) {
      CommonExtension().showToast('Please input description');
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    showLoading().whenComplete(() {
      if (isVideo) {
        String b_name = "fast-socialbook";
        String f_name = path.basename(image);
        String c_type = "video/*";
        final params = {
          "bucket": b_name,
          "file_name": f_name,
          "content_type": c_type,
        };
        api.getPresignedUrl(params).then((url) async {
          if (url == null) {
            hideLoading();
            CommonExtension().showToast('Oops failed');
          } else {
            var res = await put(Uri.parse(url), body: File(image).readAsBytesSync());
            hideLoading();
            if (res.statusCode == 200) {
              var imageUrl = url.split("?")[0];
              api.startSocialPost(description: text, effectKey: effectKey, resources: [
                DiscoveryResource(type: DiscoveryResourceType.video.value(), url: imageUrl),
                DiscoveryResource(type: DiscoveryResourceType.image.value(), url: originalUrl),
              ]).then((value) {
                if (value != null) {
                  CommonExtension().showToast("Your shares are under review and will be shown in Discovery later");
                  Navigator.pop(context, true);
                }
              });
            } else {
              CommonExtension().showToast("Failed to upload image");
            }
          }
        });
      } else {
        String b_name = "fast-socialbook";
        String f_name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        String c_type = "image/*";
        final params = {
          "bucket": b_name,
          "file_name": f_name,
          "content_type": c_type,
        };
        api.getPresignedUrl(params).then((url) async {
          if (url == null) {
            hideLoading();
            CommonExtension().showToast('Oops failed');
          } else {
            var res = await put(Uri.parse(url), body: imageData);
            hideLoading();
            if (res.statusCode == 200) {
              var imageUrl = url.split("?")[0];
              api.startSocialPost(description: text, effectKey: effectKey, resources: [
                DiscoveryResource(type: DiscoveryResourceType.image.value(), url: imageUrl),
                DiscoveryResource(type: DiscoveryResourceType.image.value(), url: originalUrl),
              ]).then((value) {
                if (value != null) {
                  CommonExtension().showToast("Your share will be released after admin approve");
                  Navigator.pop(context, true);
                }
              });
            } else {
              CommonExtension().showToast("Failed to upload image");
            }
          }
        });
      }
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
        blurAble: false,
        backIcon: TitleTextWidget(
          StringConstant.cancel,
          ColorConstant.White,
          FontWeight.normal,
          $(16),
        ),
        trailing: TitleTextWidget(
          StringConstant.discoveryShareRelease,
          canSubmit ? ColorConstant.White : ColorConstant.EffectFunctionGrey,
          FontWeight.normal,
          $(16),
        )
            .intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(12), vertical: $(4)),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular($(6)),
                    gradient: LinearGradient(
                      colors: [
                        canSubmit ? Color(0xffE31ECD) : ColorConstant.EffectGrey,
                        canSubmit ? Color(0xff243CFF) : ColorConstant.EffectGrey,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )))
            .intoGestureDetector(onTap: () {
          if (canSubmit) {
            submit();
          }
        }),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: textEditingController,
              autofocus: true,
              inputFormatters: [
                LengthLimitingTextInputFormatter(_maxInputLength),
              ],
              textInputAction: TextInputAction.done,
              style: TextStyle(height: 1, color: ColorConstant.White),
              maxLines: 3,
              minLines: 1,
              onChanged: (text) {
                setState(() {
                  canSubmit = text.trim().isNotEmpty;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: StringConstant.discoveryShareInputHint,
                hintStyle: TextStyle(
                  color: ColorConstant.DiscoveryCommentGrey,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: $(12), vertical: $(12)),
                isDense: true,
              ),
            ),
            SizedBox(height: $(40)),
            (isVideo ? EffectVideoPlayer(url: image) : Image.memory(imageData!)).intoContainer(
                padding: EdgeInsets.symmetric(
              horizontal: $(8),
            )),
          ],
        ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(25))),
      ),
    );
  }
}
