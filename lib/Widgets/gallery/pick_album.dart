import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/image/medium_image_provider.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:photo_manager/photo_manager.dart';

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
  }) async {
    Map<Permission, PermissionStatus> map = await [Permission.photos, Permission.storage].request();
    for (var key in map.keys) {
      var value = map[key];
      if (value!.isDenied || value.isPermanentlyDenied) {
        CommonExtension().showToast('Please grant $key permission');
        return [];
      }
    }
    return Navigator.of(context).push<List<AssetEntity>>(MaterialPageRoute(
      builder: (context) => _PickAlbumScreen(
        switchAlbum: switchAlbum,
        selectedList: selectedList ?? [],
        badList: badList ?? [],
        maxCount: count,
        minCount: minCount,
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

  _PickAlbumScreen({
    Key? key,
    required this.switchAlbum,
    required this.selectedList,
    required this.maxCount,
    this.minCount = 1,
    required this.badList,
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

  CacheManager cacheManager = AppDelegate.instance.getManager();

  _PickAlbumScreenState() : super(canCancelOnLoading: false);

  @override
  void initState() {
    super.initState();
    maxCount = widget.maxCount;
    minCount = widget.minCount;
    if (maxCount == 1) {
      crossCount = 4;
      spacing = $(4);
      imageSize = (ScreenUtil.screenSize.width - $(12)) / crossCount;
      padding = EdgeInsets.zero;
    } else {
      crossCount = 3;
      spacing = $(6);
      imageSize = (ScreenUtil.screenSize.width - $(48)) / crossCount;
      padding = EdgeInsets.all($(12));
    }
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
                    selectAlbum = albums.pick((t) => t.id == lastAlbumId) ?? albums.pick((t) => (t.name ?? '').toLowerCase().contains('camera')) ?? albums.first;
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
    return Scaffold(
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
            leading: maxCount == 1
                ? null
                : Text(
                    '${selectedList.length}/${maxCount}',
                    style: TextStyle(color: Colors.white),
                  ).intoContainer(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: selectedList.isEmpty ? ColorConstant.CardColor : ColorConstant.EffectCardColor,
                    )),
            middle: albums.isNotEmpty && switchAlbum
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FutureBuilder<int>(
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return Text(
                              '${selectAlbum?.name} (${snapshot.data})' ?? '',
                              style: TextStyle(
                                color: ColorConstant.White,
                                fontSize: $(17),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            );
                          }
                          return Container();
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
                        .push(NoAnimRouter(AlbumPopup(
                      albums: albums,
                      selectedAlbum: selectAlbum!,
                    )))
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
            trailing: maxCount == 1
                ? null
                : Text(
                    S.of(context).ok,
                    style: TextStyle(color: Colors.white),
                  )
                    .intoContainer(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: selectedList.length < minCount ? ColorConstant.CardColor : ColorConstant.BlueColor,
                        ))
                    .intoGestureDetector(onTap: () {
                    if (selectedList.length < minCount) {
                      return;
                    }
                    Navigator.of(context).pop(selectedList);
                  }),
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
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    var data = dataList[index];
    bool isBad = badList.exist((t) => t.id == data.id);
    bool selected = selectedList.exist((t) => t.id == data.id);
    return Container(
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
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: $(22),
                          ),
                          top: 4,
                          right: 4,
                        )
                      : Positioned(
                          child: Icon(
                            Icons.check,
                            color: ColorConstant.White,
                            size: $(16),
                          ).intoContainer(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: selected ? Colors.green : ColorConstant.White),
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
        Navigator.of(context).pop([data]);
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
}
