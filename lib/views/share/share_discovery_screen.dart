import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/bad_words.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/selected_button.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/api/downloader.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/share/share_term_view.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:path/path.dart' as path;
import 'package:posthog_flutter/posthog_flutter.dart';

const int _maxInputLength = 512;

class ShareDiscoveryScreen extends StatefulWidget {
  static Future<bool?> push(
    BuildContext context, {
    String? originalUrl,
    required String image,
    required bool isVideo,
    required String effectKey,
    required HomeCardType category,
    String? payload,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ShareDiscoveryScreen(
          isVideo: isVideo,
          originalUrl: originalUrl,
          image: image,
          effectKey: effectKey,
          category: category,
          payload: payload,
        ),
        settings: RouteSettings(name: "/ShareDiscoveryScreen"),
      ),
    );
  }

  String? originalUrl;
  String image;
  bool isVideo;
  String effectKey;
  String? payload;
  HomeCardType category;

  ShareDiscoveryScreen({
    Key? key,
    this.originalUrl,
    required this.image,
    required this.isVideo,
    required this.effectKey,
    required this.category,
    this.payload,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ShareDiscoveryState();
  }
}

class ShareDiscoveryState extends AppState<ShareDiscoveryScreen> {
  bool canSubmit = true;
  late bool isVideo;
  late String image;
  String? originalUrl;
  Uint8List? imageData;
  late TextEditingController textEditingController;
  late CartoonizerApi api;
  late String effectKey;
  bool includeOriginal = true;
  Size? imageSize;
  FocusNode focusNode = new FocusNode();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  String textHint = '';
  String? payload;
  late TapGestureRecognizer termTap;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'share_discovery_screen');
    api = CartoonizerApi().bindState(this);
    textEditingController = TextEditingController();
    // canSubmit = textEditingController.text.trim().isNotEmpty;
    isVideo = widget.isVideo;
    image = widget.image;
    originalUrl = widget.originalUrl;
    effectKey = widget.effectKey;
    termTap = TapGestureRecognizer();
    payload = widget.payload;
    if (!isVideo) {
      imageData = base64Decode(image);
    }

    delay(() {
      switch (widget.category) {
        case HomeCardType.ai_avatar:
          textHint = S.of(context).discoveryShareInputHint.replaceAll('%s', '#PandoraAvatar');
          break;
        case HomeCardType.cartoonize:
          textHint = S.of(context).discoveryShareInputHint.replaceAll('%s', "#Cartoonizer");
          break;
        case HomeCardType.anotherme:
          textHint = S.of(context).discoveryShareInputHint.replaceAll('%s', "#Me-taverse");
          break;
        case HomeCardType.txt2img:
          textHint = S.of(context).discoveryShareInputHint.replaceAll('%s', "#AITextToImage");
          break;
        case HomeCardType.scribble:
          textHint = S.of(context).discoveryShareInputHint.replaceAll('%s', "#AIScribble");
          break;
        case HomeCardType.stylemorph:
          textHint = S.of(context).discoveryShareInputHint.replaceAll('%s', "#StyleMorph");
          break;
        case HomeCardType.metagram:
          textHint = S.of(context).discoveryShareInputHint.replaceAll('%s', "#Metagram");
          break;
        case HomeCardType.lineart:
          textHint = S.of(context).discoveryShareInputHint.replaceAll('%s', "#AiColoring");
          break;
        case HomeCardType.UNDEFINED:
          break;
      }
      FocusScope.of(context).requestFocus(focusNode);
      if (cacheManager.containKey(CacheManager.postOfTerm) == false) {
        cacheManager.setBool(CacheManager.postOfTerm, false);
        showShareTermDialog(context, () {
          bool isAgree = cacheManager.getBool(CacheManager.postOfTerm);
          if (isAgree != true) {
            cacheManager.setBool(CacheManager.postOfTerm, true);
            setState(() {});
          }
        });
      }
    }, milliseconds: 500);
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    textEditingController.dispose();
  }

  String getBadWord(String text) {
    text = text.toLowerCase();
    for (String word in bad_words) {
      if (text.contains("$word ") || text.contains("$word,") || text.contains("$word.") || text.contains("$word!")) {
        return word;
      }
    }
    return "";
  }

  submit() {
    if (cacheManager.getBool(CacheManager.postOfTerm) != true) {
      CommonExtension().showToast(S.of(context).selectTermOfPost);
      return;
    }
    var text = textEditingController.text.trim();
    if (text.isEmpty) {
      text = textHint;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    String badWord = getBadWord(text);
    if (badWord.isNotEmpty) {
      CommonExtension().showToast(S.of(context).InputBadWord.replaceAll('%s', badWord));
      return;
    }
    showLoading().whenComplete(() {
      if (isVideo) {
        GallerySaver.saveVideo(image, false).then((value) {
          if (value == null) {
            hideLoading();
            CommonExtension().showToast(S.of(context).commonFailedToast);
          } else {
            uploadFile(value, needCompress: false).then((value) async {
              if (value == null) {
                hideLoading();
                CommonExtension().showToast(S.of(context).commonFailedToast);
              } else {
                var imageUrl = value.key;
                var list = [
                  DiscoveryResource(type: DiscoveryResourceType.video.value(), url: imageUrl),
                ];
                if (includeOriginal && originalUrl != null) {
                  var fileType = originalUrl!.substring(originalUrl!.lastIndexOf(".") + 1);
                  if (fileType.isEmpty) {
                    fileType = "jpg";
                  }
                  var fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileType';
                  var tempDir = cacheManager.storageOperator.tempDir;
                  var originFilePath = tempDir.path + '/$fileName';
                  var response = await Downloader().downloadSync(originalUrl!, originFilePath);
                  if (response?.statusCode != 200) {
                    hideLoading();
                    CommonExtension().showToast(S.of(context).commonFailedToast);
                    return;
                  }
                  var keyValue = await uploadFile(originFilePath, needCompress: true);
                  if (keyValue == null) {
                    hideLoading();
                    CommonExtension().showToast(S.of(context).commonFailedToast);
                    return;
                  }
                  list.add(
                    DiscoveryResource(type: DiscoveryResourceType.image.value(), url: keyValue.key),
                  );
                }
                api
                    .startSocialPost(
                        description: text,
                        effectKey: effectKey,
                        resources: list,
                        category: widget.category.value(),
                        payload: payload,
                        onUserExpired: () {
                          AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'token_expired', callback: () {
                            submit();
                          }, autoExec: true);
                        })
                    .then((value) {
                  hideLoading();
                  if (value != null) {
                    EventBusHelper().eventBus.fire(OnNewPostEvent());
                    Navigator.pop(context, true);
                  }
                });
              }
            });
          }
        });
      } else {
        String b_name = "fast-socialbook";
        String f_name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        String c_type = "image/jpg";
        final params = {
          "bucket": b_name,
          "file_name": f_name,
          "content_type": c_type,
        };
        api.getPresignedUrl(params).then((url) async {
          if (url == null) {
            hideLoading();
            CommonExtension().showToast(S.of(context).commonFailedToast);
          } else {
            Uint8List image = await imageCompressWithList(imageData!);
            var baseEntity = await Uploader().upload(url, image, c_type);
            if (baseEntity != null) {
              var imageUrl = url.split("?")[0];
              var list = [
                DiscoveryResource(type: DiscoveryResourceType.image.value(), url: imageUrl),
              ];
              if (includeOriginal && originalUrl != null) {
                var fileType = originalUrl!.substring(originalUrl!.lastIndexOf(".") + 1);
                if (fileType.isEmpty) {
                  fileType = "jpg";
                }
                var fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileType';
                var tempDir = cacheManager.storageOperator.tempDir;
                var originFilePath = tempDir.path + '/$fileName';
                var response = await Downloader().downloadSync(originalUrl!, originFilePath);
                if (response?.statusCode != 200) {
                  hideLoading();
                  CommonExtension().showToast(S.of(context).commonFailedToast);
                  return;
                }
                var keyValue = await uploadFile(originFilePath, needCompress: true);
                if (keyValue == null) {
                  hideLoading();
                  CommonExtension().showToast(S.of(context).commonFailedToast);
                  return;
                }
                list.add(
                  DiscoveryResource(type: DiscoveryResourceType.image.value(), url: keyValue.key),
                );
              }
              api
                  .startSocialPost(
                      description: text,
                      effectKey: effectKey,
                      resources: list,
                      category: widget.category.value(),
                      payload: payload,
                      onUserExpired: () {
                        AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'token_expired', callback: () {
                          submit();
                        }, autoExec: true);
                      })
                  .then((value) {
                hideLoading();
                if (value != null) {
                  EventBusHelper().eventBus.fire(OnNewPostEvent());
                  Navigator.pop(context, true);
                }
              });
            } else {
              hideLoading();
              CommonExtension().showToast(S.of(context).failed_to_upload_image);
            }
          }
        });
      }
    });
  }

  Future<MapEntry<String, BaseEntity>?> uploadFile(String filePath, {required bool needCompress}) async {
    String b_name = "fast-socialbook";
    String f_name = path.basename(filePath);
    var fileType = f_name.substring(f_name.lastIndexOf(".") + 1);
    if (TextUtil.isEmpty(fileType)) {
      fileType = '*';
    }
    String c_type = "${needCompress ? 'image' : 'video'}/$fileType";
    final params = {
      "bucket": b_name,
      "file_name": f_name,
      "content_type": c_type,
    };
    var url = await api.getPresignedUrl(params);
    if (url == null) {
      return null;
    }
    if (needCompress) {
      File image = await imageCompressAndGetFile(File(filePath));
      var baseEntity = await Uploader().uploadFile(url, image, c_type);
      if (baseEntity != null) {
        return MapEntry(url.split("?")[0], baseEntity);
      } else {
        return null;
      }
    } else {
      var baseEntity = await Uploader().uploadFile(url, File(filePath), c_type);
      if (baseEntity != null) {
        return MapEntry(url.split("?")[0], baseEntity);
      } else {
        return null;
      }
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: ColorConstant.BackgroundColor,
          appBar: AppNavigationBar(
            backgroundColor: Colors.transparent,
            blurAble: false,
            backIcon: TitleTextWidget(
              S.of(context).cancel,
              ColorConstant.White,
              FontWeight.normal,
              $(16),
            ).intoContainer(margin: EdgeInsets.only(left: $(10))),
            backAction: () async {
              if (focusNode.hasFocus) {
                FocusScope.of(context).requestFocus(FocusNode());
                await delay(() {}, milliseconds: 300);
              }
              Navigator.of(context).pop();
            },
            trailing: TitleTextWidget(
              S.of(context).discoveryShareSubmit,
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
              // if (canSubmit) {
              submit();
              // }
            }),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: textEditingController,
                  autofocus: false,
                  focusNode: focusNode,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(_maxInputLength),
                  ],
                  style: TextStyle(
                    height: 1,
                    color: ColorConstant.White,
                    fontFamily: 'Poppins',
                    fontSize: $(14),
                  ),
                  maxLines: 5,
                  minLines: 3,
                  // onChanged: (text) {
                  // setState(() {
                  // canSubmit = text.trim().isNotEmpty;
                  // });
                  // },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: textHint,
                    hintStyle: TextStyle(
                      color: ColorConstant.DiscoveryCommentGrey,
                      fontFamily: 'Poppins',
                      fontSize: $(14),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: $(6), vertical: $(12)),
                    isDense: true,
                  ),
                ),
                SizedBox(height: $(60)),
                Row(
                  children: [
                    originalUrl == null
                        ? Container()
                        : Expanded(
                            child: includeOriginal && imageSize != null
                                ? Container(
                                    width: imageSize!.width,
                                    height: imageSize!.height,
                                    child: CachedNetworkImageUtils.custom(
                                      context: context,
                                      imageUrl: originalUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container()),
                    SizedBox(width: $(8)),
                    Expanded(
                        child: (isVideo
                                ? EffectVideoPlayer(url: image)
                                : Image.memory(
                                    imageData!,
                                    fit: BoxFit.cover,
                                  ))
                            .intoContainer()
                            .visibility(
                              visible: imageSize != null,
                              maintainSize: true,
                              maintainState: true,
                              maintainAnimation: true,
                            )
                            .listenSizeChanged(onSizeChanged: (size) {
                      setState(() {
                        imageSize = size;
                      });
                    })),
                    SizedBox(width: $(8)),
                    Expanded(child: Container()),
                  ],
                ),
                SizedBox(height: $(22)),
                Divider(height: 1, color: ColorConstant.EffectGrey),
                SizedBox(height: $(18)),
                originalUrl == null
                    ? Container()
                    : SelectedButton(
                        selected: includeOriginal,
                        selectedImage: Row(
                          children: [
                            Image.asset(Images.ic_checked, width: $(16)),
                            SizedBox(width: $(6)),
                            TitleTextWidget(S.of(context).shareIncludeOriginal, ColorConstant.White, FontWeight.normal, $(14)),
                          ],
                        ),
                        normalImage: Row(
                          children: [
                            Image.asset(Images.ic_unchecked, width: $(16)),
                            SizedBox(width: $(6)),
                            TitleTextWidget(S.of(context).shareIncludeOriginal, ColorConstant.EffectGrey, FontWeight.normal, $(14)),
                          ],
                        ),
                        onChange: (value) {
                          setState(() {
                            includeOriginal = value;
                          });
                        },
                      ),
                SizedBox(
                  height: $(15),
                ),
                Row(
                  children: [
                    Image.asset(cacheManager.getBool(CacheManager.postOfTerm) ? Images.ic_checked : Images.ic_unchecked, width: $(16)).intoGestureDetector(onTap: () {
                      bool isAgree = cacheManager.getBool(CacheManager.postOfTerm);
                      cacheManager.setBool(CacheManager.postOfTerm, !isAgree);
                      setState(() {});
                    }),
                    SizedBox(width: $(6)),
                    Expanded(
                        child: RichText(
                      text: TextSpan(text: S.of(context).IHaveReadAndAgreeTo, style: TextStyle(fontSize: $(14)), children: [
                        TextSpan(
                            text: S.of(context).TermsOfUse,
                            style: TextStyle(color: ColorConstant.BlueColor),
                            recognizer: termTap
                              ..onTap = () {
                                showShareTermDialog(context, () {
                                  bool isAgree = cacheManager.getBool(CacheManager.postOfTerm);
                                  if (isAgree != true) {
                                    cacheManager.setBool(CacheManager.postOfTerm, true);
                                    setState(() {});
                                  }
                                });
                              }),
                      ]),
                      maxLines: 3,
                    )),
                  ],
                )
              ],
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(25))),
          ),
        ),
        onWillPop: () async {
          if (focusNode.hasFocus) {
            FocusScope.of(context).requestFocus(FocusNode());
            await delay(() {}, milliseconds: 300);
          }
          return true;
        });
  }
}
