import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/photo_view/photo_pager.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/views/discovery/discovery_comments_list_screen.dart';
import 'package:cartoonizer/views/discovery/user_discovery_screen.dart';
import 'package:cartoonizer/views/discovery/widget/user_info_header_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'widget/discovery_attr_holder.dart';

class DiscoveryEffectDetailScreen extends StatefulWidget {
  DiscoveryListEntity data;

  DiscoveryEffectDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DiscoveryEffectDetailState();
}

class DiscoveryEffectDetailState extends AppState<DiscoveryEffectDetailScreen> with DiscoveryAttrHolder {
  UserManager userManager = AppDelegate.instance.getManager();
  late DiscoveryListEntity data;
  late List<String> images;
  Size? imageSize;
  late CartoonizerApi api;
  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;

  @override
  void initState() {
    super.initState();
    api = CartoonizerApi().bindState(this);
    data = widget.data.copy();
    images = data.images.split(",");
    if (images.isEmpty) {
      CommonExtension().showToast("Oops Failed!");
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
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
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
                  builder: (BuildContext context) => UserDiscoveryScreen(
                    userId: data.userId,
                    title: isMe ? StringConstant.setting_my_discovery : null,
                  ),
                  settings: RouteSettings(name: "/UserDiscoveryScreen"),
                ),
              );
            }).intoContainer(margin: EdgeInsets.only(left: $(15), right: $(15), top: $(25), bottom: 0)),
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
            Row(
              children: [
                Expanded(
                    child: CachedNetworkImage(
                  imageUrl: images[0],
                  cacheManager: CachedImageCacheManager(),
                ).listenSizeChanged(onSizeChanged: (size) {
                  setState(() {
                    imageSize = size;
                  });
                }).intoGestureDetector(onTap: () => open(context, 0))),
                SizedBox(width: $(2)),
                Expanded(
                  child: (images.length > 1 && imageSize != null)
                      ? CachedNetworkImage(
                          imageUrl: images[1],
                          fit: BoxFit.cover,
                          cacheManager: CachedImageCacheManager(),
                        )
                          .intoContainer(
                            width: imageSize!.width,
                            height: imageSize!.height,
                          )
                          .intoGestureDetector(onTap: () => open(context, 1))
                      : Container(),
                ),
              ],
            ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
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
                SizedBox(width: $(15)),
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
                  onTap: () {},
                )
                .intoContainer(
                  margin: EdgeInsets.only(left: $(15), right: $(15), top: $(45), bottom: $(20)),
                ),
          ],
        ),
      ),
    );
  }

  void open(BuildContext context, final int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => GalleryPhotoViewWrapper(
          galleryItems: images,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index,
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
}
