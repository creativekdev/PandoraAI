import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/photo_view/photo_pager.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/views/transfer/ChoosePhotoScreen.dart';
import 'package:cartoonizer/views/discovery/discovery_effect_detail_screen.dart';
import 'package:cartoonizer/views/discovery/my_discovery_screen.dart';
import 'package:cartoonizer/views/discovery/widget/user_info_header_widget.dart';
import 'package:mmoo_forbidshot/mmoo_forbidshot.dart';

import 'discovery_attr_holder.dart';

class DiscoveryEffectDetailWidget extends StatefulWidget {
  DiscoveryListEntity data;
  LoadingAction loadingAction;

  DiscoveryEffectDetailWidget({
    Key? key,
    required this.data,
    required this.loadingAction,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DiscoveryEffectDetailWidgetState();
}

class DiscoveryEffectDetailWidgetState extends State<DiscoveryEffectDetailWidget> with DiscoveryAttrHolder {
  UserManager userManager = AppDelegate.instance.getManager();
  EffectManager effectManager = AppDelegate.instance.getManager();
  late DiscoveryListEntity data;
  late LoadingAction loadingAction;
  Size? imageSize;
  late double imageListWidth;
  late CartoonizerApi api;
  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  late StreamSubscription onCreateCommentListener;
  List<DiscoveryResource> resources = [];
  EffectDataController effectDataController = Get.find();

  @override
  void initState() {
    super.initState();
    api = CartoonizerApi().bindState(this);
    loadingAction = widget.loadingAction;
    data = widget.data.copy();
    resources = data.resourceList();
    if (resources.isEmpty) {
      CommonExtension().showToast(StringConstant.commonFailedToast);
      Navigator.pop(context);
    }
    onLoginEventListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (event.data ?? true) {
        refreshData();
      } else {}
    });
    onLikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryLikeEvent>().listen((event) {
      var id = event.data!.key;
      var likeId = event.data!.value;
      if (data.id == id) {
        data.likeId = likeId;
        data.likes++;
        setState(() {});
      }
    });
    onUnlikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryUnlikeEvent>().listen((event) {
      if (data.id == event.data) {
        data.likeId = null;
        data.likes--;
        setState(() {});
      }
    });
    onCreateCommentListener = EventBusHelper().eventBus.on<OnCreateCommentEvent>().listen((event) {
      if (event.data?.length == 1) {
        if (data.id == event.data![0]) {
          setState(() {
            data.comments++;
          });
        }
      }
    });
    imageListWidth = ScreenUtil.screenSize.width - $(30);
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    onLoginEventListener.cancel();
    onLikeEventListener.cancel();
    onUnlikeEventListener.cancel();
    onCreateCommentListener.cancel();
  }

  refreshData() {
    loadingAction.showLoadingBar().whenComplete(() {
      api.getDiscoveryDetail(data.id).then((value) {
        loadingAction.hideLoadingBar().whenComplete(() {
          if (value != null) {
            setState(() {
              data = value;
            });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserInfoHeaderWidget(avatar: data.userAvatar, name: data.userName).intoGestureDetector(onTap: () {
          UserManager userManager = AppDelegate.instance.getManager();
          bool isMe = userManager.user?.id == data.userId;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => MyDiscoveryScreen(
                userId: data.userId,
                title: isMe ? StringConstant.setting_my_discovery : null,
              ),
              settings: RouteSettings(name: "/UserDiscoveryScreen"),
            ),
          );
        }).intoContainer(
          margin: EdgeInsets.only(left: $(15), right: $(15), top: $(10), bottom: 0),
        ),
        Text(
          data.text,
          style: TextStyle(color: ColorConstant.White, fontSize: $(15), fontFamily: 'Poppins'),
        ).intoContainer(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: $(6), horizontal: $(15)),
        ),
        resources.length > 1
            ? Row(
                children: [
                  buildResourceItem(
                    resources[0],
                    width: (imageListWidth - $(2)) / 2,
                  ).listenSizeChanged(onSizeChanged: (size) {
                    if (size.height < 1920) {
                      setState(() {
                        imageSize = size;
                      });
                    }
                  }).intoGestureDetector(onTap: () {
                    if (resources[0].type == 'image') {
                      openImage(context, 0);
                    }
                  }),
                  SizedBox(width: $(2)).offstage(offstage: resources.length <= 1),
                  imageSize != null
                      ? buildResourceItem(
                          resources[1],
                          width: (imageListWidth - $(2)) / 2,
                          height: imageSize!.height,
                        ).intoGestureDetector(onTap: () {
                          if (resources[1].type == 'image') {
                            openImage(context, 1);
                          }
                        })
                      : Container(),
                ],
              ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)))
            : buildResourceItem(resources[0], width: imageListWidth).intoGestureDetector(onTap: () {
                if (resources[0].type == 'image') {
                  openImage(context, 0);
                }
              }),
        Row(
          children: [
            buildAttr(context, iconRes: Images.ic_discovery_comment, value: data.comments, axis: Axis.horizontal),
            SizedBox(width: $(10)),
            buildAttr(
              context,
              iconRes: data.likeId == null ? Images.ic_discovery_like : Images.ic_discovery_liked,
              iconColor: data.likeId == null ? ColorConstant.White : ColorConstant.Red,
              value: data.likes,
              axis: Axis.horizontal,
              onTap: () {
                userManager.doOnLogin(context, callback: () {
                  onLikeTap();
                }, autoExec: false);
              },
            ),
          ],
        ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(6))),
        OutlineWidget(
          strokeWidth: $(2),
          radius: $(6),
          gradient: LinearGradient(
            colors: [Color(0xffE31ECD), Color(0xff243CFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          child: ShaderMask(
            shaderCallback: (Rect bounds) => LinearGradient(
              colors: [Color(0xffE31ECD), Color(0xff243CFF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(Offset.zero & bounds.size),
            blendMode: BlendMode.srcATop,
            child: TitleTextWidget(
              StringConstant.discoveryDetailsUseSameTemplate,
              Color(0xffffffff),
              FontWeight.w700,
              $(15),
            ).intoContainer(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: $(10), vertical: $(10)),
            ),
          ),
        )
            .intoGestureDetector(onTap: () => toChoosePage())
            .intoContainer(margin: EdgeInsets.only(left: $(15), right: $(15), top: $(0), bottom: $(8)))
            .visibility(visible: imageSize != null || resources.length == 1),
      ],
    );
  }

  Widget buildResourceItem(DiscoveryResource resource, {required double width, double? height}) {
    if (resource.type == DiscoveryResourceType.video.value()) {
      return EffectVideoPlayer(url: resource.url ?? '').intoContainer(height: (ScreenUtil.screenSize.width - $(32)) / 2);
    } else {
      return CachedNetworkImageUtils.custom(
          context: context,
          imageUrl: resource.url ?? '',
          fit: BoxFit.cover,
          width: width,
          height: height,
          cacheManager: CachedImageCacheManager(),
          placeholder: (context, url) {
            return CircularProgressIndicator()
                .intoContainer(
                  width: $(25),
                  height: $(25),
                )
                .intoCenter()
                .intoContainer(width: width, height: height ?? width);
          },
          errorWidget: (context, url, error) {
            return CircularProgressIndicator()
                .intoContainer(
                  width: $(25),
                  height: $(25),
                )
                .intoCenter()
                .intoContainer(width: width, height: height ?? width);
          });
    }
  }

  void openImage(BuildContext context, final int index) {
    if(Platform.isAndroid) {
      FlutterForbidshot.setAndroidForbidOn();
    }
    List<String> images = resources.filter((t) => t.type == DiscoveryResourceType.image.value()).map((e) => e.url ?? '').toList();
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => GalleryPhotoViewWrapper(
          galleryItems: images,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index >= images.length ? 0 : index,
          scrollDirection: Axis.horizontal,
        ),
      ),
    ).then((value) {
      if(Platform.isAndroid) {
        FlutterForbidshot.setAndroidForbidOff();
      }
    });
  }

  onLikeTap() => loadingAction.showLoadingBar().whenComplete(() {
        if (data.likeId == null) {
          api.discoveryLike(data.id).then((value) {
            loadingAction.hideLoadingBar();
          });
        } else {
          api.discoveryUnLike(data.id, data.likeId!).then((value) {
            loadingAction.hideLoadingBar();
          });
        }
      });

  toChoosePage() {
    String key = data.cartoonizeKey;
    int tabPos = effectDataController.data!.tabPos(key);
    int categoryPos = 0;
    int itemPos = 0;
    if (tabPos == -1) {
      CommonExtension().showToast("This template is not available now");
      return;
    }
    var targetSeries = effectDataController.data!.targetSeries(key)!;
    EffectModel? effectModel;
    EffectItem? effectItem;
    int index = 0;
    for (int i = 0; i < targetSeries.value.length; i++) {
      if (effectModel != null) {
        break;
      }
      var model = targetSeries.value[i];
      var list = model.effects.values.toList();
      for (int j = 0; j < list.length; j++) {
        var item = list[j];
        if (item.key == key) {
          effectModel = model;
          effectItem = item;
          index = i;
          break;
        }
      }
    }
    if (effectItem == null) {
      CommonExtension().showToast("This template is not available now");
      return;
    }
    categoryPos = effectDataController.tabTitleList.findPosition((data) => data.categoryKey == effectModel!.key)!;
    itemPos = effectDataController.tabItemList.findPosition((data) => data.data.key == effectItem!.key)!;
    logEvent(Events.choose_home_cartoon_type, eventValues: {
      "category": targetSeries.value[index].key,
      "style": targetSeries.value[index].style,
      "page": 'discovery',
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ChoosePhotoScreen"),
        builder: (context) => ChoosePhotoScreen(
          tabPos: tabPos,
          pos: categoryPos,
          itemPos: itemPos,
          entrySource: EntrySource.fromDiscovery,
        ),
      ),
    );
  }
}