import 'dart:ui';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/image/sync_download_image.dart';
import 'package:cartoonizer/Widgets/photo_view/any_photo_pager.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/models/avatar_ai_list_entity.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class SaveAvatarsScreen extends StatefulWidget {
  List<AvatarChildEntity> outputImages;

  SaveAvatarsScreen({
    Key? key,
    required this.outputImages,
  }) : super(key: key);

  @override
  State<SaveAvatarsScreen> createState() => _SaveAvatarsScreenState();
}

class _SaveAvatarsScreenState extends AppState<SaveAvatarsScreen> {
  late List<AvatarChildEntity> outputImages;
  List<String> selectedList = [];
  late double imageSize;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'save_avatars_screen');
    outputImages = widget.outputImages;
    imageSize = (ScreenUtil.screenSize.width - $(6)) / 3;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstant.BackgroundColor,
        body: Stack(
          children: [
            GridView.builder(
              padding: EdgeInsets.only(
                bottom: $(82) + ScreenUtil.getBottomPadding(context),
                top: $(46) + ScreenUtil.getStatusBarHeight(),
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: $(3), crossAxisSpacing: $(3)),
              itemBuilder: (context, index) {
                var url = outputImages[index].url;
                bool checked = selectedList.contains(url);
                return Stack(
                  children: [
                    CachedNetworkImageUtils.custom(
                      useOld: true,
                      context: context,
                      imageUrl: url,
                      width: imageSize,
                      height: imageSize,
                    ).hero(tag: url).intoContainer(
                          width: imageSize,
                          height: imageSize,
                        ),
                    Positioned(
                      child: checked
                          ? Icon(
                              Icons.check,
                              size: $(16),
                              color: ColorConstant.White,
                            ).intoContainer(
                              width: $(20),
                              height: $(20),
                              padding: EdgeInsets.all($(2)),
                              decoration: BoxDecoration(
                                color: ColorConstant.BlueColor,
                                borderRadius: BorderRadius.circular(32),
                              ))
                          : Container(
                              width: $(20),
                              height: $(20),
                              decoration: BoxDecoration(
                                  color: Color(0x26000000),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: Color(0xffffffff),
                                    width: 1,
                                  )),
                            ),
                      top: 8,
                      right: 10,
                    ),
                  ],
                )
                    .intoContainer(
                  width: imageSize,
                  height: imageSize,
                )
                    .intoGestureDetector(onTap: () {
                  if (checked) {
                    selectedList.remove(url);
                  } else {
                    selectedList.add(url);
                  }
                  setState(() {});
                  // openImage(context, outputImages[index]);
                });
              },
              itemCount: outputImages.length,
            ),
            AppNavigationBar(
              blurAble: true,
              backgroundColor: ColorConstant.BackgroundColorBlur,
              middle: TitleTextWidget(S.of(context).download, ColorConstant.White, FontWeight.w500, $(17)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  selectedList.length == outputImages.length
                      ? Icon(
                          Icons.check,
                          size: $(14),
                          color: ColorConstant.White,
                        ).intoContainer(
                          width: $(18),
                          height: $(18),
                          padding: EdgeInsets.all($(2)),
                          decoration: BoxDecoration(
                            color: ColorConstant.BlueColor,
                            borderRadius: BorderRadius.circular(32),
                          ))
                      : Container(
                          width: $(18),
                          height: $(18),
                          decoration: BoxDecoration(
                              color: Color(0x26000000),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Color(0xffffffff),
                                width: 1,
                              )),
                        ),
                  SizedBox(width: $(6)),
                  Text(
                    S.of(context).all,
                    style: TextStyle(
                      color: ColorConstant.White,
                      fontSize: $(14),
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ).intoContainer(color: Colors.transparent).intoGestureDetector(onTap: () {
                if (selectedList.length != outputImages.length) {
                  selectedList = outputImages.map((e) => e.url).toList();
                } else {
                  selectedList.clear();
                }
                setState(() {});
              }),
            ).intoContainer(height: $(46) + ScreenUtil.getStatusBarHeight()),
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Row(
                    children: [
                      Text(
                        S.of(context).preview,
                        style: TextStyle(
                          color: selectedList.isEmpty ? Colors.grey : Colors.white,
                          fontSize: $(14),
                          fontFamily: 'Poppins',
                        ),
                      ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(10))).intoGestureDetector(onTap: () async {
                        if (selectedList.isEmpty) {
                          return;
                        }
                        openImage(context, 0, selectedList);
                      }),
                      Expanded(child: Container()),
                      Text(
                        S.of(context).ok,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: $(14),
                          fontFamily: 'Poppins',
                        ),
                      )
                          .intoContainer(
                              padding: EdgeInsets.symmetric(horizontal: $(30), vertical: $(8)),
                              decoration: BoxDecoration(color: ColorConstant.BlueColor, borderRadius: BorderRadius.circular($(6))),
                              margin: EdgeInsets.only(right: $(15)))
                          .intoGestureDetector(onTap: () {
                        if (selectedList.isEmpty) {
                          CommonExtension().showToast(S.of(context).select_min_photos_hint.replaceAll('%d', '1'));
                          return;
                        }
                        saveAllPhoto(context);
                      })
                    ],
                  )
                      .intoContainer(
                    width: double.maxFinite,
                    height: $(80),
                    padding: EdgeInsets.only(bottom: 25),
                    alignment: Alignment.center,
                  )
                      .intoGestureDetector(
                    onTap: () {
                      if (selectedList.isEmpty) {
                        CommonExtension().showToast(S.of(context).please_select_photos);
                        return;
                      }
                      saveAllPhoto(context);
                    },
                  ).intoContainer(
                    color: ColorConstant.BackgroundColorBlur,
                    padding: EdgeInsets.only(
                      bottom: ScreenUtil.getBottomPadding(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Future<void> saveAllPhoto(BuildContext context) async {
    showSaveAlertDialog(context, count: selectedList.length).then((value) {
      if (value ?? false) {
        showLoading().whenComplete(() async {
          for (int i = 0; i < selectedList.length; i++) {
            var item = selectedList[i];
            var file = await SyncDownloadImage(url: item, type: 'png').getImage();
            if (file != null) {
              showLoading(
                  progressWidget: Text(
                '${i + 1}/${selectedList.length}',
                style: TextStyle(
                  color: ColorConstant.White,
                  fontFamily: 'Poppins',
                ),
              ));
              await GallerySaver.saveImage(file.path, albumName: 'Pandora Avatars');
            }
          }
          Events.avatarResultDownloadOkClick(saveType: selectedList.length == outputImages.length ? "Save All" : "Save Select");
          hideLoading().whenComplete(() {
            CommonExtension().showImageSavedOkToast(context);
            delay(() {
              UserManager userManager = AppDelegate.instance.getManager();
              userManager.rateNoticeOperator.onSwitch(context);
            }, milliseconds: 2000);
          });
        });
      }
    });
  }

  Future<bool?> showSaveAlertDialog(BuildContext context, {required int count}) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            S.of(context).save_album_tips.replaceAll('%d', '${count}'),
            style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
            textAlign: TextAlign.center,
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
          Row(
            children: [
              Expanded(
                  child: Text(
                S.of(context).cancel,
                style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
              )
                      .intoContainer(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                            top: BorderSide(color: ColorConstant.LineColor, width: 1),
                          )))
                      .intoGestureDetector(onTap: () {
                Navigator.pop(context, false);
              })),
              Expanded(
                  child: Text(
                S.of(context).confirm,
                style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: ColorConstant.BlueColor),
              )
                      .intoContainer(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                            top: BorderSide(color: ColorConstant.LineColor, width: 1),
                            right: BorderSide(color: ColorConstant.LineColor, width: 1),
                          )))
                      .intoGestureDetector(onTap: () async {
                Navigator.pop(context, true);
              })),
            ],
          ),
        ],
      )
          .intoMaterial(
            color: ColorConstant.EffectFunctionGrey,
            borderRadius: BorderRadius.circular($(16)),
          )
          .intoContainer(
            padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
            margin: EdgeInsets.symmetric(horizontal: $(35)),
          )
          .intoCenter(),
    );
  }

  void openImage(BuildContext context, final int index, List<String> files) {
    List<AnyPhotoItem> images = files.transfer((e, index) => AnyPhotoItem(type: AnyPhotoType.url, uri: e));
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => AnyGalleryPhotoViewWrapper(
          galleryItems: images,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index >= images.length ? 0 : index,
          needSave: false,
        ),
      ),
    );
  }
}
