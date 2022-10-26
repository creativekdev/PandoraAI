import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/nsfw_card.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/push_extra_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/effect/effect_tab_state.dart';
import 'package:cartoonizer/views/effect/widget/card_ads_widget.dart';
import 'package:cartoonizer/views/transfer/ChoosePhotoScreen.dart';

import '../../Widgets/dialog/dialog_widget.dart';

class EffectRandomFragment extends StatefulWidget {
  RecentController recentController;
  EffectDataController dataController;
  String tabString;
  int tabId;

  EffectRandomFragment({
    Key? key,
    required this.tabId,
    required this.recentController,
    required this.tabString,
    required this.dataController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EffectRandomFragmentState();
  }
}

class EffectRandomFragmentState extends State<EffectRandomFragment> with AutomaticKeepAliveClientMixin, AppTabState, EffectTabState {
  late RecentController recentController;
  late EffectDataController dataController;
  ScrollController scrollController = ScrollController();
  double marginTop = $(115);
  late double cardWidth;
  late StreamSubscription appStateListener;
  late StreamSubscription tabOnDoubleClickListener;
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  UserManager userManager = AppDelegate.instance.getManager();
  late bool nsfwOpen;
  int? selectedTagIndex;

  String? get selectedTag => selectedTagIndex == null ? null : dataController.tagList[selectedTagIndex!];

  setSelectedTagIndex(int? index) {
    setState(() {
      if (index == null) {
        selectedTagIndex = null;
      } else {
        selectedTagIndex = index;
      }
    });
  }

  @override
  initState() {
    super.initState();
    nsfwOpen = cacheManager.getBool(CacheManager.nsfwOpen);
    marginTop = $(115) + ScreenUtil.getStatusBarHeight();
    dataController = widget.dataController;
    recentController = widget.recentController;
    cardWidth = (ScreenUtil.screenSize.width - $(38)) / 2;
    appStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      setState(() {});
    });
    tabOnDoubleClickListener = EventBusHelper().eventBus.on<OnTabDoubleClickEvent>().listen((event) {
      if (event.data == widget.tabId) {
        scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.linear);
      }
    });
  }

  @override
  onAttached() {
    super.onAttached();
    dataController.changeRandomTabViewing(true);
    var nsfw = cacheManager.getBool(CacheManager.nsfwOpen);
    if (nsfwOpen != nsfw) {
      setState(() {
        nsfwOpen = nsfw;
      });
    }
  }

  @override
  onDetached() {
    super.onDetached();
    dataController.changeRandomTabViewing(false);
    dataController.buildRandomList();
  }

  @override
  dispose() {
    super.dispose();
    appStateListener.cancel();
    tabOnDoubleClickListener.cancel();
  }

  List<List<_ListData>> addToDataList(EffectDataController dataController) {
    List<EffectItemListData> list;
    if (selectedTag == null) {
      list = dataController.randomList;
    } else {
      list = dataController.randomList.filter((t) => t.item!.tagList.exist((tag) => tag == selectedTag));
    }
    List<List<_ListData>> result = [];
    List<_ListData> allList = [];
    var showAdsNew = isShowAdsNew();
    for (int i = 0; i < list.length; i++) {
      int page = i ~/ 10;
      if (showAdsNew && i % 10 == 5) {
        // todo
        // allList.add(_ListData(isAd: true, page: page));
      }
      var data = list[i];
      allList.add(_ListData(
        page: page,
        data: data,
        visible: true,
      ));
    }
    for (var value in allList) {
      if (result.isEmpty || result.last.length == 2) {
        result.add([value]);
      } else {
        result.last.add(value);
      }
    }
    return result;
  }

  @override
  onEffectClick(PushExtraEntity pushExtraEntity) {
    for (var value in dataController.randomList) {
      if (value.key == pushExtraEntity.category && value.item!.key == pushExtraEntity.effect) {
        _onEffectCategoryTap(value, dataController);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Stack(children: [
          GetBuilder<EffectDataController>(
              init: dataController,
              builder: (dataController) {
                List<List<_ListData>> dataList = addToDataList(dataController);
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: $(15)),
                  itemBuilder: (context, i) {
                    var list = dataList[i];
                    return Row(
                      children: list.transfer((data, index) {
                        var data = list[index];
                        if (data.isAd) {
                          return _buildMERCAd(cardWidth, cardWidth).intoContainer(
                              width: cardWidth,
                              height: cardWidth,
                              margin: EdgeInsets.only(
                                left: index % 2 == 0 ? 0 : $(6),
                                top: $(6),
                                bottom: i == dataList.length ? (AppTabBarHeight + $(15)) : $(0),
                              ));
                        }
                        var nfwShown = data.data!.item!.nsfw && !nsfwOpen;
                        return Container(
                          width: cardWidth,
                          height: cardWidth,
                          margin: EdgeInsets.only(
                            left: index % 2 == 0 ? 0 : $(6),
                            top: i == 0 ? marginTop + (dataController.tagList.isNotEmpty ? $(40) : 0) : $(6),
                          ),
                          child: data.data!.item!.imageUrl.contains('mp4')
                              ? Stack(
                                  children: [
                                    EffectVideoPlayer(url: data.data!.item!.imageUrl).intoGestureDetector(onTap: () => _onEffectCategoryTap(data.data!, dataController)),
                                    Positioned(
                                      right: $(5),
                                      top: $(5),
                                      child: Image.asset(
                                        ImagesConstant.ic_video,
                                        height: $(24),
                                        width: $(24),
                                      ),
                                    ),
                                    nfwShown ? Container(width: cardWidth, height: cardWidth).blur() : SizedBox.shrink(),
                                    nfwShown
                                        ? NsfwCard(
                                            width: cardWidth,
                                            height: cardWidth,
                                            onTap: () {
                                              showOpenNsfwDialog(context).then((result) {
                                                if (result ?? false) {
                                                  setState(() {
                                                    nsfwOpen = true;
                                                    cacheManager.setBool(CacheManager.nsfwOpen, true);
                                                  });
                                                }
                                              });
                                            },
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                )
                              : Stack(
                                  children: [
                                    // CachedNetworkImageUtils.custom(
                                    //     // useOld: true,
                                    //     context: context,
                                    //     imageUrl: data.data!.item!.imageUrl,
                                    //     width: cardWidth,
                                    //     height: cardWidth,
                                    //     fit: BoxFit.fill,
                                    //     placeholder: (context, url) {
                                    //       return CircularProgressIndicator()
                                    //           .intoContainer(width: $(25), height: $(25))
                                    //           .intoCenter()
                                    //           .intoContainer(width: cardWidth, height: cardWidth);
                                    //     },
                                    //     errorWidget: (context, url, error) {
                                    //       return CircularProgressIndicator()
                                    //           .intoContainer(
                                    //             width: $(25),
                                    //             height: $(25),
                                    //           )
                                    //           .intoCenter()
                                    //           .intoContainer(width: cardWidth, height: cardWidth);
                                    //     }).intoGestureDetector(onTap: () => _onEffectCategoryTap(data.data!, dataController)),
                                    // Container().blur(),
                                    CachedNetworkImageUtils.custom(
                                        // useOld: false,
                                        context: context,
                                        imageUrl: data.data!.item!.imageUrl,
                                        width: cardWidth,
                                        height: cardWidth,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) {
                                          return CircularProgressIndicator()
                                              .intoContainer(width: $(25), height: $(25))
                                              .intoCenter()
                                              .intoContainer(width: cardWidth, height: cardWidth);
                                        },
                                        errorWidget: (context, url, error) {
                                          return CircularProgressIndicator()
                                              .intoContainer(
                                                width: $(25),
                                                height: $(25),
                                              )
                                              .intoCenter()
                                              .intoContainer(width: cardWidth, height: cardWidth);
                                        }).intoGestureDetector(onTap: () => _onEffectCategoryTap(data.data!, dataController)),
                                    nfwShown ? Container(width: cardWidth, height: cardWidth).blur() : SizedBox.shrink(),
                                    nfwShown
                                        ? NsfwCard(
                                            width: cardWidth,
                                            height: cardWidth,
                                            onTap: () {
                                              showOpenNsfwDialog(context).then((result) {
                                                if (result ?? false) {
                                                  setState(() {
                                                    nsfwOpen = true;
                                                    cacheManager.setBool(CacheManager.nsfwOpen, true);
                                                  });
                                                }
                                              });
                                            },
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                        );
                      }),
                    ).intoContainer(
                      margin: EdgeInsets.only(bottom: i == dataList.length - 1 ? (AppTabBarHeight + $(42)) : $(0)),
                    );
                  },
                  itemCount: dataList.length,
                  controller: scrollController,
                );
              }),
          buildHashTagList(dataController),
        ]));
  }

  Widget buildHashTagList(EffectDataController dataController) {
    if (dataController.tagList.isEmpty) {
      return Container(height: marginTop);
    }
    return ScrollablePositionedList.builder(
            scrollDirection: Axis.horizontal,
            initialScrollIndex: 0,
            padding: EdgeInsets.only(left: $(8), right: $(8)),
            physics: ClampingScrollPhysics(),
            itemCount: dataController.tagList.length,
            itemBuilder: (context, index) {
              var selected = index == selectedTagIndex;
              return (selected
                      ? ShaderMask(
                          shaderCallback: (Rect bounds) => LinearGradient(
                            colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomRight,
                          ).createShader(Offset.zero & bounds.size),
                          blendMode: BlendMode.srcATop,
                          child: Text(
                            '# ${dataController.tagList[index]}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: ColorConstant.White,
                              fontSize: $(13),
                            ),
                          ),
                        )
                      : Text(
                          '# ${dataController.tagList[index]}',
                          style: TextStyle(
                            fontSize: $(13),
                            fontFamily: 'Poppins',
                            color: ColorConstant.BlueColor,
                          ),
                        ))
                  .intoContainer(padding: EdgeInsets.symmetric(vertical: $(10), horizontal: $(10)))
                  .intoGestureDetector(onTap: () {
                if (selected) {
                  setSelectedTagIndex(null);
                } else {
                  setSelectedTagIndex(index);
                }
              });
            })
        .intoContainer(
          height: $(44),
          alignment: Alignment.center,
          color: Color(0xdd161719),
        )
        .blur()
        .intoContainer(
          margin: EdgeInsets.only(top: marginTop - 22),
        );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildMERCAd(double width, double height) {
    var showAds = isShowAdsNew();

    if (showAds) {
      var appBackground = thirdpartManager.appBackground;
      if (appBackground) {
        return const SizedBox();
      } else {
        return CardAdsWidget(
          width: width,
          height: height,
        );
      }
    }

    return Container();
  }

  _onEffectCategoryTap(EffectItemListData data, EffectDataController effectDataController) async {
    EffectModel? effectModel;
    var effectList = effectDataController.data!.effectList('template');
    for (int i = 0; i < effectList.length; i++) {
      var value = effectList[i];
      if (data.key == value.key) {
        effectModel = EffectModel.fromJson(value.toJson());
        break;
      }
    }
    if (effectModel == null) {
      return;
    }
    var tabPos = effectDataController.tabList.findPosition((data) => data.key == widget.tabString)!;
    var categoryPos = effectDataController.tabTitleList.findPosition((data) => data.categoryKey == effectModel!.key)!;
    var itemP = effectDataController.tabItemList.findPosition((d) => d.data.key == data.item!.key)!;

    logEvent(Events.choose_home_cartoon_type, eventValues: {
      "category": effectModel.key,
      "style": effectModel.style,
      "page": widget.tabString,
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ChoosePhotoScreen"),
        builder: (context) => ChoosePhotoScreen(
          tabPos: tabPos,
          pos: categoryPos,
          itemPos: itemP,
        ),
      ),
    );

    refreshUserInfo();
  }

  void refreshUserInfo() {
    userManager.refreshUser(context: context).then((value) {
      setState(() {});
    });
  }
}

class _ListData {
  bool isAd;
  int page;
  EffectItemListData? data;
  bool visible;

  _ListData({
    this.isAd = false,
    this.data,
    required this.page,
    this.visible = true,
  });
}
