import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/photo_view/photo_pager.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
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
import 'package:cartoonizer/views/ChoosePhotoScreen.dart';
import 'package:cartoonizer/views/discovery/discovery_comments_list_screen.dart';
import 'package:cartoonizer/views/discovery/my_discovery_screen.dart';
import 'package:cartoonizer/views/discovery/widget/user_info_header_widget.dart';

import 'widget/discovery_attr_holder.dart';

class DiscoveryEffectDetailScreen extends StatefulWidget {
  DiscoveryListEntity data;
  bool autoToComments;

  DiscoveryEffectDetailScreen({Key? key, required this.data, this.autoToComments = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DiscoveryEffectDetailState();
}

class DiscoveryEffectDetailState extends AppState<DiscoveryEffectDetailScreen> with DiscoveryAttrHolder {
  UserManager userManager = AppDelegate.instance.getManager();
  EffectManager effectManager = AppDelegate.instance.getManager();
  late DiscoveryListEntity data;
  Size? imageSize;
  late double imageListWidth;
  late CartoonizerApi api;
  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  late StreamSubscription onCreateCommentListener;
  List<DiscoveryResource> resources = [];

  @override
  void initState() {
    super.initState();
    logEvent(Events.discovery_detail_loading);
    api = CartoonizerApi().bindState(this);
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
    delay(() {
      if (widget.autoToComments) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => DiscoveryCommentsListScreen(
              discoveryEntity: data,
            ),
            settings: RouteSettings(name: "/DiscoveryCommentsListScreen"),
          ),
        );
      }
    });
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
    showLoading().whenComplete(() {
      api.getDiscoveryDetail(data.id).then((value) {
        hideLoading().whenComplete(() {
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
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppNavigationBar(
        backgroundColor: Colors.black,
        middle: TitleTextWidget(StringConstant.discoveryDetails, ColorConstant.BtnTextColor, FontWeight.w600, $(18)),
        trailing: TitleTextWidget('Delete', ColorConstant.BtnTextColor, FontWeight.w600, $(15)).intoGestureDetector(onTap: () {
          showDeleteDialog();
        }).visibility(visible: userManager.user?.id == data.userId),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserInfoHeaderWidget(
              avatar: data.userAvatar,
              name: data.userName,
            ).intoGestureDetector(onTap: () {
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
            }).intoContainer(margin: EdgeInsets.only(left: $(15), right: $(15), top: $(25), bottom: 0), constraints: BoxConstraints(minHeight: $(30))),
            Text(
              data.text,
              style: TextStyle(
                color: ColorConstant.White,
                fontSize: $(15),
                fontFamily: 'Poppins',
              ),
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
                          open(context, 0);
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
                                open(context, 1);
                              }
                            })
                          : Container(),
                    ],
                  ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)), constraints: BoxConstraints(minHeight: $(100)))
                : buildResourceItem(resources[0], width: imageListWidth).intoGestureDetector(onTap: () {
                    if (resources[0].type == 'image') {
                      open(context, 0);
                    }
                  }),
            Row(
              children: [
                buildAttr(context, iconRes: Images.ic_discovery_comment, value: data.comments, axis: Axis.horizontal, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => DiscoveryCommentsListScreen(
                        discoveryEntity: data,
                      ),
                      settings: RouteSettings(name: "/DiscoveryCommentsListScreen"),
                    ),
                  );
                }),
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
                  $(16),
                ).intoContainer(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: $(12), vertical: $(12)),
                ),
              ),
            )
                .intoGestureDetector(
                  onTap: () {
                    toChoosePage();
                  },
                )
                .intoContainer(
                  margin: EdgeInsets.only(left: $(15), right: $(15), top: $(45), bottom: $(20)),
                )
                .visibility(visible: imageSize != null || resources.length == 1),
          ],
        ),
      ),
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

  void open(BuildContext context, final int index) {
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
    );
  }

  onLikeTap() => showLoading().whenComplete(() {
        if (data.likeId == null) {
          api.discoveryLike(data.id).then((value) {
            hideLoading();
          });
        } else {
          api.discoveryUnLike(data.id, data.likeId!).then((value) {
            hideLoading();
          });
        }
      });

  toChoosePage() {
    String key = data.cartoonizeKey;
    showLoading().whenComplete(() {
      effectManager.loadData().then((value) {
        hideLoading().whenComplete(() {
          if (value == null) {
            return;
          }
          var targetSeries = value.targetSeries(key);
          if (targetSeries == null) {
            CommonExtension().showToast("This template is not available now");
            return;
          }
          EffectItem? effectItem;
          int index = 0;
          int itemIndex = 0;
          for (int i = 0; i < targetSeries.value.length; i++) {
            var model = targetSeries.value[i];
            var list = model.effects.values.toList();
            for (int j = 0; j < list.length; j++) {
              var item = list[j];
              if (item.key == key) {
                effectItem = item;
                index = i;
                itemIndex = j;
                break;
              }
            }
          }
          if (effectItem == null) {
            return;
          }
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
                list: targetSeries.value,
                pos: index,
                itemPos: itemIndex,
                entrySource: EntrySource.fromDiscovery,
                hasOriginalCheck: false,
                tabString: targetSeries.key,
              ),
            ),
          );
        });
      });
    });
  }

  delete() {
    showLoading().whenComplete(() {
      api.deleteDiscovery(data.id).then((value) {
        hideLoading().whenComplete(() {
          if (value != null) {
            CommonExtension().showToast('Delete succeed');
            Navigator.of(context).pop();
          }
        });
      });
    });
  }

  showDeleteDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure to delete this post?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: ColorConstant.White),
                ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      'Delete',
                      style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.red),
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
                      Navigator.pop(context);
                      delete();
                    })),
                    Expanded(
                        child: Text(
                      'Cancel',
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
                      Navigator.pop(context);
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
                .intoCenter());
  }
}
