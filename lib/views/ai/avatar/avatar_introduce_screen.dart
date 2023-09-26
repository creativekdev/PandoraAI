import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/avatar_config_entity.dart';
import 'package:cartoonizer/views/ai/avatar/dialog/choose_create_avatar_style_dialog.dart';
import 'package:cartoonizer/views/transfer/cartoonizer/choose_tab_bar.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/widgets/outline_widget.dart';
import 'package:cartoonizer/widgets/photo_view/any_photo_pager.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'avatar.dart';

class AvatarIntroduceScreen extends StatefulWidget {
  String source;

  AvatarIntroduceScreen({
    Key? key,
    required this.source,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AvatarIntroduceScreenState();
}

class AvatarIntroduceScreenState extends AppState<AvatarIntroduceScreen> {
  List<String> dataList = [];
  Size? size;
  int selectedStyleIndex = 0;
  late StreamSubscription streamSubscription;
  CacheManager cacheManager = AppDelegate().getManager();

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'avatar_ai_introduction_screen');
    Events.avatarCreate(source: widget.source);
    streamSubscription = EventBusHelper().eventBus.on<OnCreateAvatarAiEvent>().listen((event) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(backgroundColor: ColorConstant.BackgroundColor),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: $(10)),
            shaderMask(
                context: context,
                child: Text(
                  S.of(context).what_to_expect,
                  style: TextStyle(
                    color: ColorConstant.White,
                    fontSize: $(26),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                )),
            SizedBox(height: $(15)),
            TitleTextWidget(S.of(context).expect_details, ColorConstant.White, FontWeight.w400, $(13), maxLines: 10).intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(25)),
            ),
            Image.asset(
              Images.ic_avatar_ai_planet,
              height: $(60),
            ).intoContainer(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(
                  horizontal: $(15),
                ),
                margin: EdgeInsets.only(bottom: $(6))),
            TitleTextWidget(S.of(context).guidelines, Colors.white, FontWeight.bold, $(17), maxLines: 3).intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(35)),
            ),
            SizedBox(height: $(35)),
            shaderMask(
                context: context,
                child: Text(
                  S.of(context).examples,
                  style: TextStyle(
                    color: ColorConstant.White,
                    fontSize: $(18),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                )),
            FutureBuilder(
              builder: (context, snapShot) {
                if (snapShot.data == null) {
                  return Container();
                }
                var config = snapShot.data! as AvatarConfig;
                var roles = config.getRoles();
                var lastAvatarConfig = cacheManager.getJson(CacheManager.lastCreateAvatar);
                String? selectedStyle;
                if (lastAvatarConfig != null) {
                  selectedStyle = lastAvatarConfig['style']?.toString();
                }
                if (roles.contains(selectedStyle ?? '')) {
                  selectedStyleIndex = roles.indexOf(selectedStyle!);
                } else {
                  selectedStyleIndex = 0;
                }
                var roleImages = config.getRoleImages().values.toList();
                var style = roles[selectedStyleIndex];
                var examples = config.examples(style);
                return Column(
                  children: [
                    SizedBox(height: $(10)),
                    ChooseTabBar(
                        scrollable: roleImages.length > 4,
                        tabList: roleImages,
                        currentIndex: selectedStyleIndex,
                        onTabClick: (index) {
                          var lastAvatarConfig = cacheManager.getJson(CacheManager.lastCreateAvatar);
                          if (lastAvatarConfig == null) {
                            lastAvatarConfig = {};
                          }
                          lastAvatarConfig['style'] = roles[index];
                          cacheManager.setJson(CacheManager.lastCreateAvatar, lastAvatarConfig).then((value) {
                            setState(() {
                              selectedStyleIndex = index;
                            });
                          });
                        },
                        itemBuilder: (context, index, value, checked) {
                          var image = CachedNetworkImageUtils.custom(
                            context: context,
                            imageUrl: value,
                            height: $(55),
                            width: $(55),
                          );
                          return OutlineWidget(
                              radius: $(8),
                              strokeWidth: $(3),
                              gradient: LinearGradient(
                                colors: [checked ? Color(0xffE31ECD) : Colors.transparent, checked ? Color(0xff243CFF) : Colors.transparent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              child: image.intoContainer(margin: EdgeInsets.all($(2))));
                        },
                        height: $(60)),
                    SizedBox(height: $(10)),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(left: $(12), right: $(12), bottom: $(12)),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: $(6),
                        crossAxisSpacing: $(6),
                      ),
                      itemBuilder: (context, index) {
                        return buildItem(context, index, examples);
                      },
                      itemCount: examples.length,
                    ),
                  ],
                );
              },
              future: AppDelegate().getManager<AvatarAiManager>().getConfig(),
            )
          ],
        ),
      ),
      bottomNavigationBar: TitleTextWidget(S.of(context).txtContinue, ColorConstant.White, FontWeight.normal, $(17))
          .intoContainer(
            margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(15)),
            decoration: BoxDecoration(color: ColorConstant.BlueColor, borderRadius: BorderRadius.circular($(8))),
            alignment: Alignment.center,
          )
          .intoContainer(
            width: ScreenUtil.screenSize.width,
            alignment: Alignment.center,
            height: $(72),
          )
          .intoGestureDetector(onTap: () {
        Function createAction = () {};
        createAction = () {
          ChooseCreateAvatarStyle.push(context).then((nameStyle) {
            if (nameStyle != null) {
              Avatar.create(context, source: widget.source, name: nameStyle.key, style: nameStyle.value, state: this, onCancel: () {
                createAction.call();
              });
            }
          });
        };
        createAction.call();
      }).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding())),
    );
  }

  Widget buildItem(BuildContext context, int index, List<String> examples) {
    return ClipRRect(
      child: CachedNetworkImageUtils.custom(
        useOld: true,
        context: context,
        imageUrl: examples[index],
        width: (ScreenUtil.screenSize.width - $(36)) / 2,
        height: (ScreenUtil.screenSize.width - $(36)) / 2,
      ),
      borderRadius: BorderRadius.circular($(8)),
    ).hero(tag: examples[index]).intoGestureDetector(onTap: () {
      openImage(context, index, examples);
    });
  }

  void openImage(BuildContext context, final int index, List<String> examples) {
    List<AnyPhotoItem> images = examples.transfer((e, index) => AnyPhotoItem(type: AnyPhotoType.url, uri: e));
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
        ),
      ),
    );
  }
}
