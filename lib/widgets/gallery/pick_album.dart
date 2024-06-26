import 'dart:io';

import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/image/medium_image_provider.dart';
import 'package:cartoonizer/widgets/photo_view/any_photo_pager.dart';
import 'package:cartoonizer/widgets/router/routers.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'albums_popup.dart';
import 'pick_album_navigation_bar.dart';

const leadingTag = 'album_leading';
const middleTag = 'album_middle';

class PickAlbumScreen {
  static Future<List<AssetEntity>?> pickImage(
    BuildContext context, {
    List<AssetEntity>? selectedList,
    List<AssetEntity>? badList,
    int count = 20,
    int minCount = 1,
    bool switchAlbum = false,
    HomeCardType? type,
  }) async {
    if (!await PermissionsUtil.checkPermissions()) {
      return [];
    }
    return Navigator.of(context).push<List<AssetEntity>>(MaterialPageRoute(
      settings: RouteSettings(name: '/_PickAlbumScreen'),
      builder: (context) => _PickAlbumScreen(
        switchAlbum: switchAlbum,
        selectedList: selectedList ?? [],
        badList: badList ?? [],
        maxCount: count,
        minCount: minCount,
        type: type,
      ),
    ));
  }
}

class _PickAlbumScreen extends StatefulWidget {
  bool switchAlbum;
  List<AssetEntity> selectedList;
  int maxCount;
  List<AssetEntity> badList;
  int minCount;
  HomeCardType? type;

  _PickAlbumScreen({
    Key? key,
    required this.switchAlbum,
    required this.selectedList,
    required this.maxCount,
    this.minCount = 1,
    required this.badList,
    this.type,
  }) : super(key: key);

  @override
  State<_PickAlbumScreen> createState() => _PickAlbumScreenState();
}

class _PickAlbumScreenState extends AppState<_PickAlbumScreen> {
  List<AssetPathEntity> albums = [];
  AssetPathEntity? selectAlbum;
  int page = 0;
  int pageSize = 40;
  List<AssetEntity> dataList = [];
  bool _isRequesting = false;
  bool _canLoadMore = false;
  ScrollController scrollController = ScrollController();
  late bool switchAlbum;
  late List<AssetEntity> selectedList;
  late List<AssetEntity> badList;
  late int maxCount;
  late int minCount;

  late double imageSize;
  late EdgeInsets padding;
  late double spacing;
  late int crossCount;
  List<String> loadFailedList = [];
  int albumCount = 0;
  bool guided = false;
  HomeCardType? type;

  GlobalKey guideKey = GlobalKey();
  CacheManager cacheManager = AppDelegate.instance.getManager();

  _PickAlbumScreenState() : super(canCancelOnLoading: false);

  TutorialCoachMark createTutorial(GlobalKey? key) {
    TutorialCoachMark tutorial = TutorialCoachMark(
        textSkip: "",
        targets: [
          TargetFocus(
            identify: 'Step 1',
            keyTarget: key,
            contents: [
              TargetContent(
                  align: ContentAlign.bottom,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: $(30)),
                          child: Text(
                            S.of(context).how_to_use_desc,
                            style: TextStyle(color: Colors.white, fontSize: $(14)),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: $(30)),
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: Color(0xFF000000).withOpacity(0.2), // 阴影的颜色
                              offset: Offset(0, $(8)), // 阴影的偏移量
                              blurRadius: $(8), // 阴影的模糊半径
                              spreadRadius: $(6), // 阴影的扩散半径
                            )
                          ]),
                          child: Image.asset(
                            Images.ic_demo_coloring_result,
                            width: $(300),
                            height: $(369),
                          ),
                        ),
                        SizedBox(height: $(30)),
                      ],
                    ),
                  )),
            ],
          ),
        ],
        // List<TargetFocus>
        colorShadow: Color(0xff000000),
        opacityShadow: 0.52,
        // alignSkip: Alignment.bottomRight,
        // textSkip: "SKIP",
        paddingFocus: $(15),
        onFinish: () {
          setState(() {
            guided = true;
          });
          print("finish");
        },
        onClickTargetWithTapPosition: (target, tapDetails) {
          print("target: $target");
          print("clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
        },
        onClickTarget: (target) {
          print(target);
        },
        onSkip: () {
          setState(() {
            guided = true;
          });
          print("skip");
        });
    return tutorial;
    // tutorial.skip();
    // tutorial.finish();
    // tutorial.next(); // call next target programmatically
    // tutorial.previous(); // call previous target programmatically
  }

  loadGuide() {
    if (type == HomeCardType.lineart) {
      var tutorial = createTutorial(guideKey);
      tutorial.show(context: context);
    } else {
      setState(() {
        guided = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    type = widget.type;
    maxCount = widget.maxCount;
    minCount = widget.minCount;
    crossCount = 4;
    spacing = $(2);
    imageSize = (ScreenUtil.screenSize.width - $(12)) / crossCount;
    padding = EdgeInsets.zero;
    selectedList = [...widget.selectedList];
    badList = [...widget.badList];
    switchAlbum = widget.switchAlbum;
    scrollController.addListener(() {
      if (_isRequesting) {
        return;
      }
      if (_canLoadMore && scrollController.position.pixels > scrollController.position.maxScrollExtent - 20) {
        loadMore();
      }
    });
    guided = type == null;
    delay(() => showLoading().whenComplete(() {
          PhotoManager.getAssetPathList(type: RequestType.image).then((value) async {
            value = await value.filterSync((t) async => await t.assetCountAsync != 0);
            hideLoading().whenComplete(() async {
              albums = value;
              if (value.isEmpty) {
                selectAlbum = null;
              } else {
                if (selectAlbum == null) {
                  if (switchAlbum) {
                    var lastAlbumId = cacheManager.getString(CacheManager.lastAlbum);
                    selectAlbum = albums.pick((t) => t.id == lastAlbumId) ?? albums.pick((t) => (t.name).toLowerCase().contains('camera')) ?? albums.first;
                  } else {
                    AssetPathEntity? s;
                    for (var album in albums) {
                      if (s == null) {
                        s = album;
                      } else {
                        var count = await album.assetCountAsync;
                        var oldCount = await s.assetCountAsync;
                        if (count > oldCount) {
                          s = album;
                        }
                      }
                    }
                    selectAlbum = s;
                  }
                }
                selectAlbum?.assetCountAsync.then((value) {
                  albumCount = value;
                });
              }
              setState(() {});
              if (selectAlbum != null) {
                loadData();
              }
            });
          });
        }));
  }

  void loadData() async {
    _isRequesting = true;
    var count = await selectAlbum!.assetCountAsync;
    selectAlbum!
        .getAssetListRange(
      start: 0,
      end: pageSize < count ? pageSize : count,
    )
        .then((value) async {
      setState(() {
        page = 0;
        dataList = value;
      });
      _isRequesting = false;
      if (dataList.length >= count) {
        _canLoadMore = false;
      } else {
        _canLoadMore = true;
      }
      if (!guided) {
        delay(() => loadGuide(), milliseconds: 200);
      }
    });
  }

  void loadMore() async {
    _isRequesting = true;
    var skip = (page + 1) * pageSize;
    var count = await selectAlbum!.assetCountAsync;
    selectAlbum!
        .getAssetListRange(
      start: skip,
      end: pageSize + skip < count ? pageSize + skip : count,
    )
        .then((value) async {
      if (value.isNotEmpty) {
        setState(() {
          page++;
          dataList.addAll(value);
        });
      }
      _isRequesting = false;
      if (dataList.length >= count) {
        _canLoadMore = false;
      } else {
        _canLoadMore = true;
      }
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: ColorConstant.BackgroundColor,
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              PickAlbumNavigationBar(
                backIcon: Image.asset(
                  Images.ic_back,
                  height: $(22),
                  width: $(22),
                ).hero(tag: leadingTag),
                middle: albums.isNotEmpty && switchAlbum
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FutureBuilder<int>(
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                return Text(
                                  '${selectAlbum?.name} (${snapshot.data})',
                                  style: TextStyle(
                                    color: ColorConstant.White,
                                    fontSize: $(17),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  ),
                                );
                              }
                              return Text(
                                '${selectAlbum?.name} (${albumCount})',
                                style: TextStyle(
                                  color: ColorConstant.White,
                                  fontSize: $(17),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              );
                            },
                            future: selectAlbum!.assetCountAsync,
                          ).intoMaterial(color: Colors.transparent),
                          SizedBox(width: 6),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: $(18),
                            color: Color(0xff404040),
                          ).intoContainer(decoration: BoxDecoration(color: ColorConstant.White, borderRadius: BorderRadius.circular(32))),
                        ],
                      )
                        .intoContainer(
                        padding: EdgeInsets.only(top: 3, bottom: 3, left: 12, right: 10),
                        decoration: BoxDecoration(
                          color: Color(0xff404040),
                          borderRadius: BorderRadius.circular($(64)),
                        ),
                      )
                        .intoGestureDetector(onTap: () {
                        Navigator.of(context)
                            .push(
                          NoAnimRouter(
                            AlbumPopup(albums: albums, selectedAlbum: selectAlbum!),
                            settings: RouteSettings(name: '/AlbumPopup'),
                          ),
                        )
                            .then((value) {
                          if (value != null) {
                            setState(() {
                              selectAlbum = value;
                              cacheManager.setString(CacheManager.lastAlbum, value.id);
                              loadData();
                            });
                          }
                        });
                      })
                    : TitleTextWidget(S.of(context).choose_photo, ColorConstant.White, FontWeight.w500, $(17)),
              ),
              Expanded(
                  child: GridView.builder(
                cacheExtent: $(120),
                controller: scrollController,
                padding: padding,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                ),
                itemBuilder: (context, index) {
                  return buildItem(context, index);
                },
                itemCount: dataList.length,
              )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).album_to_settings_tips,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: $(12),
                      color: Color(0xff9f9f9f),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    S.of(context).album_to_settings_button,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: $(12),
                      color: Color(0xff2778FF),
                    ),
                  ).intoGestureDetector(onTap: () {
                    openAppSettings();
                  }),
                ],
              )
                  .intoContainer(
                      padding: EdgeInsets.only(
                    top: $(10),
                    bottom: maxCount > 1 ? $(15) : ScreenUtil.getBottomPadding() + $(15),
                  ))
                  .offstage(offstage: !Platform.isIOS),
              Row(
                children: [
                  Text(
                    S.of(context).preview,
                    style: TextStyle(
                      color: selectedList.isEmpty ? Colors.grey : Colors.white,
                      fontSize: $(14),
                      fontFamily: 'Poppins',
                    ),
                  ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(10))).intoGestureDetector(onTap: () async {
                    List<String> list = [];
                    for (var value in selectedList) {
                      var file = await value.file;
                      if (file != null) {
                        list.add(file.path);
                      }
                    }
                    if (selectedList.isEmpty) {
                      return;
                    }
                    openImage(context, 0, list);
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
                          decoration:
                              BoxDecoration(color: selectedList.length < minCount ? ColorConstant.CardColor : ColorConstant.BlueColor, borderRadius: BorderRadius.circular($(6))),
                          margin: EdgeInsets.only(right: $(15)))
                      .intoGestureDetector(onTap: () {
                    if (selectedList.length < minCount) {
                      CommonExtension().showToast(S.of(context).select_min_photos_hint.replaceAll('%d', '$minCount'));
                      return;
                    }
                    pop(selectedList);
                  })
                ],
              )
                  .intoContainer(
                      padding: EdgeInsets.only(
                    top: $(10),
                    bottom: ScreenUtil.getBottomPadding() + $(15),
                  ))
                  .visibility(visible: maxCount > 1),
            ],
          ),
        ),
        onWillPop: () async {
          if (!guided) {
            return false;
          } else {
            return true;
          }
        });
  }

  Widget buildItem(BuildContext context, int index) {
    var data = dataList[index];
    bool isBad = badList.exist((t) => t.id == data.id);
    bool selected = selectedList.exist((t) => t.id == data.id);
    int pos = (selectedList.findPosition((t) => t.id == data.id) ?? 0) + 1;
    return Container(
      key: index == 0 ? guideKey : null,
      child: Stack(
        children: [
          SizedBox(
            child: Image(
              image: MediumImage(
                data,
                width: (imageSize).toInt(),
                height: (imageSize).toInt(),
                failedImageAssets: Images.ic_netimage_failed,
                onError: (medium) {
                  if (!loadFailedList.contains(medium.id)) {
                    loadFailedList.add(medium.id);
                  }
                },
              ),
              fit: BoxFit.cover,
            ),
            width: imageSize,
            height: imageSize,
          ),
          maxCount == 1
              ? Container()
              : isBad
                  ? Container(
                      width: imageSize,
                      height: imageSize,
                      color: Color(0x66000000),
                      child: Image.asset(
                        Images.ic_image_failed,
                        width: $(32),
                        height: $(32),
                        color: ColorConstant.Red,
                      ).intoCenter(),
                    )
                  : selected
                      ? Positioned(
                          child: Text(
                            '$pos',
                            style: TextStyle(color: Colors.white),
                          ),
                          top: 4,
                          left: 6,
                        )
                      : SizedBox.shrink(),
          maxCount == 1
              ? Container()
              : isBad
                  ? Container(
                      width: imageSize,
                      height: imageSize,
                      color: Color(0x66000000),
                      child: Image.asset(
                        Images.ic_image_failed,
                        width: $(32),
                        height: $(32),
                        color: ColorConstant.Red,
                      ).intoCenter(),
                    )
                  : Positioned(
                      child: Icon(
                        Icons.check,
                        color: ColorConstant.White,
                        size: $(12),
                      ).intoContainer(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: selected ? Color.fromARGB(255, 39, 120, 255) : Colors.transparent,
                          border: Border.all(color: selected ? Color.fromARGB(255, 39, 120, 255) : ColorConstant.White),
                        ),
                      ),
                      top: 6,
                      right: 6,
                    ),
        ],
      ),
      width: imageSize,
      height: imageSize,
    ).intoGestureDetector(onTap: () {
      if (isBad) {
        return;
      }
      if (loadFailedList.contains(data.id)) {
        CommonExtension().showToast(S.of(context).wrong_image);
        return;
      }
      if (maxCount == 1) {
        pop([data]);
      }
      if (selectedList.exist((t) => t.id == data.id)) {
        selectedList.removeWhere((element) => element.id == data.id);
        setState(() {});
      } else {
        if (selectedList.length < maxCount) {
          selectedList.add(data);
          setState(() {});
        }
      }
    });
  }

  void openImage(BuildContext context, final int index, List<String> files) {
    List<AnyPhotoItem> images = files.transfer((e, index) => AnyPhotoItem(type: AnyPhotoType.file, uri: e));
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
