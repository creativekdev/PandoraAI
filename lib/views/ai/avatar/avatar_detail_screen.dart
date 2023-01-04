import 'dart:io';
import 'dart:ui';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/cacheImage/sync_download_file.dart';
import 'package:cartoonizer/Widgets/photo_view/photo_pager.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/avatar_ai_list_entity.dart';
import 'package:cartoonizer/views/share/ShareUrlScreen.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:mmoo_forbidshot/mmoo_forbidshot.dart';

class AvatarDetailScreen extends StatefulWidget {
  AvatarAiListEntity entity;

  AvatarDetailScreen({
    Key? key,
    required this.entity,
  }) : super(key: key);

  @override
  State<AvatarDetailScreen> createState() => _AvatarDetailScreenState();
}

class _AvatarDetailScreenState extends AppState<AvatarDetailScreen> {
  late AvatarAiListEntity entity;
  List<List<AvatarChildEntity>> dataList = [];
  late double itemSize;
  late CartoonizerApi api;
  AvatarAiManager aiManager = AppDelegate.instance.getManager();
  CustomPopupMenuController customPopupMenuController = CustomPopupMenuController();

  _AvatarDetailScreenState() : super(canCancelOnLoading: false);

  @override
  void initState() {
    super.initState();
    logEvent(Events.avatar_detail_loading);
    api = CartoonizerApi().bindState(this);
    entity = widget.entity;
    itemSize = (ScreenUtil.screenSize.width - $(35)) / 2;
    initDataList();
  }

  void initDataList() {
    dataList.clear();
    entity.outputImages.forEach((element) {
      List<AvatarChildEntity> list;
      if (dataList.isEmpty) {
        list = [];
        dataList.add(list);
      } else if (dataList.last.length < 2 && dataList.last.first.style == element.style) {
        list = dataList.last;
      } else {
        list = [];
        dataList.add(list);
      }
      list.add(element);
    });
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.only(
              left: $(15),
              right: $(15),
              bottom: $(82) + ScreenUtil.getBottomPadding(context),
              top: $(46) + ScreenUtil.getStatusBarHeight(),
            ),
            itemBuilder: (context, index) {
              var list = dataList[index];
              if (index == 0 || dataList[index - 1].first.style != list.first.style) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: $(10)),
                    TitleTextWidget(
                      aiManager.config!.styleTitle('', list.first.style),
                      ColorConstant.White,
                      FontWeight.w500,
                      $(16),
                    ),
                    SizedBox(height: $(8)),
                    Wrap(
                      children: list
                          .map((e) => CachedNetworkImageUtils.custom(
                        context: context,
                        imageUrl: e.url,
                        width: itemSize,
                        height: itemSize,
                      )
                          .hero(tag: e.url)
                          .intoContainer(
                        width: itemSize,
                        height: itemSize,
                      )
                          .intoGestureDetector(onTap: () {
                        openImage(context, e);
                      }))
                          .toList(),
                      spacing: $(4),
                    ),
                  ],
                );
              } else {
                return Wrap(
                  children: list
                      .map((e) => CachedNetworkImageUtils.custom(
                    context: context,
                    imageUrl: e.url,
                    width: itemSize,
                    height: itemSize,
                  )
                      .hero(tag: e.url)
                      .intoContainer(
                    width: itemSize,
                    height: itemSize,
                  )
                      .intoGestureDetector(onTap: () {
                    openImage(context, e);
                  }))
                      .toList(),
                  spacing: $(4),
                ).intoContainer(margin: EdgeInsets.only(top: $(4)));
              }
            },
            itemCount: dataList.length,
          ),
          AppNavigationBar(
            backgroundColor: ColorConstant.BackgroundColorBlur,
            blurAble: true,
            middle: TitleTextWidget(entity.name, ColorConstant.White, FontWeight.w600, $(17)),
            // trailing: CustomPopupMenu(
            //   controller: customPopupMenuController,
            //   arrowColor: Colors.transparent,
            //   child: Icon(
            //     Icons.more_horiz,
            //     size: $(24),
            //     color: Colors.white,
            //   ),
            //   menuBuilder: () => IntrinsicWidth(
            //     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            //       buildPopupItem(context, title: S.of(context).share, icon: Images.ic_share, onTap: () {
            //         ShareUrlScreen.startShare(
            //           context,
            //           url: Config.instance.host + "/avatar-playground?token=" + entity.token,
            //         );
            //         customPopupMenuController.hideMenu();
            //       }),
            //       Divider(height: 1, color: ColorConstant.LineColor),
            //       buildPopupItem(context, title: S.of(context).download, icon: Images.ic_download, onTap: () {
            //         customPopupMenuController.hideMenu();
            //       }),
            //     ])
            //         .intoContainer(
            //             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            //             decoration: BoxDecoration(
            //               color: ColorConstant.White,
            //               borderRadius: BorderRadius.circular(6),
            //             ))
            //         .intoMaterial(
            //           elevation: 3,
            //           color: ColorConstant.White,
            //           borderRadius: BorderRadius.circular(6),
            //         ),
            //   ),
            //   verticalMargin: -5,
            //   horizontalMargin: 15,
            //   pressType: PressType.singleClick,
            // ),
            trailing: Image.asset(
              Images.ic_share,
              color: ColorConstant.White,
              width: $(24),
            ).hero(tag: 'download').intoGestureDetector(onTap: () {
              ShareUrlScreen.startShare(
                context,
                url: Config.instance.host + "/avatar-playground?token=" + entity.token,
              );
            }),
          ).intoContainer(height: $(46) + ScreenUtil.getStatusBarHeight()),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Text(
                  S.of(context).save_photo,
                  style: TextStyle(color: Colors.white, fontSize: $(17)),
                )
                    .intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(12)),
                  margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12)),
                  width: double.maxFinite,
                  height: $(48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular($(8)),
                    color: ColorConstant.BlueColor,
                  ),
                )
                    .intoGestureDetector(
                  onTap: () {
                    saveAllphoto(context);
                  },
                ).intoContainer(
                  color: ColorConstant.BackgroundColorBlur,
                  padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context)),
                ),
              ),
            ),
          ),
          // Text(
          //   S.of(context).play_ground,
          //   style: TextStyle(color: Colors.white, fontSize: $(17)),
          // )
          //     .intoContainer(
          //   padding: EdgeInsets.symmetric(vertical: $(12)),
          //   margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(15)),
          //   width: double.maxFinite,
          //   alignment: Alignment.center,
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular($(8)),
          //     color: ColorConstant.BlueColor,
          //   ),
          // )
          //     .intoGestureDetector(onTap: () {
          //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => AiGroundScreen()));
          // }),
        ],
      ),
    );
  }

  Widget buildPopupItem(
    BuildContext context, {
    required String title,
    required String icon,
    required GestureTapCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          icon,
          width: $(22),
          color: Colors.black,
        ),
        SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: $(15),
            color: Colors.black,
          ),
        ),
      ],
    )
        .intoContainer(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        )
        .intoGestureDetector(onTap: onTap);
  }

  Future<void> saveAllphoto(BuildContext context) async {
    showLoading().whenComplete(() async {
      var saveList = entity.outputImages;
      for (int i = 0; i < saveList.length; i++) {
        var item = saveList[i];
        var file = await SyncDownloadFile(url: item.url, type: 'png').getImage();
        if (file != null) {
          showLoading(
              progressWidget: Text(
            '${i + 1}/${entity.outputImages.length}',
            style: TextStyle(
              color: ColorConstant.White,
              fontFamily: 'Poppins',
            ),
          ));
          await GallerySaver.saveImage(file.path, albumName: 'Pandora Avatars');
        }
      }
      hideLoading().whenComplete(() {
        CommonExtension().showImageSavedOkToast(context);
      });
    });
  }

  void openImage(BuildContext context, AvatarChildEntity data) {
    if (Platform.isAndroid) {
      FlutterForbidshot.setAndroidForbidOn();
    }
    var pos = entity.outputImages.findPosition((e) => e.url == data.url) ?? 0;
    List<String> images = entity.outputImages.map((e) => e.url ?? '').toList();
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => GalleryPhotoViewWrapper(
          galleryItems: images,
          shareEnable: true,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: pos >= images.length ? 0 : pos,
          scrollDirection: Axis.horizontal,
        ),
      ),
    ).then((value) {
      if (Platform.isAndroid) {
        FlutterForbidshot.setAndroidForbidOff();
      }
    });
  }
}
