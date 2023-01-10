import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/image/medium_image_provider.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:photo_gallery/photo_gallery.dart';

class PickAlbumScreen {
  static Future<List<Medium>?> pickImage(
    BuildContext context, {
    List<Medium>? selectedList,
    List<Medium>? badList,
    int count = 20,
    bool switchAlbum = false,
  }) async {
    var value = await Permission.photos.request();
    if (value.isDenied || value.isPermanentlyDenied) {
      CommonExtension().showToast('Please grant photo permission');
      return [];
    } else {
      return Navigator.of(context).push<List<Medium>>(MaterialPageRoute(
        builder: (context) => _PickAlbumScreen(
          switchAlbum: switchAlbum,
          selectedList: selectedList ?? [],
          badList: badList ?? [],
          maxCount: count,
        ),
      ));
    }
  }
}

class _PickAlbumScreen extends StatefulWidget {
  bool switchAlbum;
  List<Medium> selectedList;
  int maxCount;
  List<Medium> badList;

  _PickAlbumScreen({
    Key? key,
    required this.switchAlbum,
    required this.selectedList,
    required this.maxCount,
    required this.badList,
  }) : super(key: key);

  @override
  State<_PickAlbumScreen> createState() => _PickAlbumScreenState();
}

class _PickAlbumScreenState extends AppState<_PickAlbumScreen> {
  List<Album> albums = [];
  Album? selectAlbum;
  int page = 0;
  int pageSize = 40;
  List<Medium> dataList = [];
  bool _isRequesting = false;
  bool _canLoadMore = false;
  ScrollController scrollController = ScrollController();
  late bool switchAlbum;
  late List<Medium> selectedList;
  late List<Medium> badList;
  late int maxCount;

  late double imageSize;

  _PickAlbumScreenState() : super(canCancelOnLoading: false);

  @override
  void initState() {
    super.initState();
    imageSize = (ScreenUtil.screenSize.width - $(48)) / 3;
    maxCount = widget.maxCount;
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
          PhotoGallery.listAlbums(mediumType: MediumType.image).then((value) {
            hideLoading().whenComplete(() {
              albums = value;
              if (value.isEmpty) {
                selectAlbum = null;
              } else {
                if (selectAlbum == null) {
                  if (switchAlbum) {
                    selectAlbum = albums.first;
                  } else {
                    Album? s;
                    for (var album in albums) {
                      if (s == null) {
                        s = album;
                      } else {
                        if (album.count > s.count) {
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

  void loadData() {
    _isRequesting = true;
    selectAlbum!
        .listMedia(
      skip: 0,
      take: pageSize < selectAlbum!.count ? pageSize : selectAlbum!.count,
    )
        .then((value) {
      setState(() {
        page = 0;
        dataList = value.items;
      });
      _isRequesting = false;
      if (dataList.length >= selectAlbum!.count) {
        _canLoadMore = false;
      } else {
        _canLoadMore = true;
      }
    });
  }

  void loadMore() {
    _isRequesting = true;
    var skip = (page + 1) * pageSize;
    selectAlbum!.listMedia(skip: skip, take: pageSize + skip < selectAlbum!.count ? pageSize : selectAlbum!.count - skip).then((value) {
      if (value.items.isNotEmpty) {
        setState(() {
          page++;
          dataList.addAll(value.items);
        });
      }
      _isRequesting = false;
      if (dataList.length >= selectAlbum!.count) {
        _canLoadMore = false;
      } else {
        _canLoadMore = true;
      }
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColorBlur,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColorBlur,
        middle: albums.isNotEmpty && switchAlbum
            ? DropdownButton<Album>(
                alignment: Alignment.center,
                dropdownColor: ColorConstant.BackgroundColor,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                underline: Container(),
                value: selectAlbum,
                onChanged: (value) {
                  setState(() {
                    selectAlbum = value;
                    loadData();
                  });
                },
                items: albums
                    .map((e) => DropdownMenuItem<Album>(
                        value: e,
                        child: Text(
                          '${e.name} (${e.count})',
                          style: TextStyle(color: ColorConstant.White),
                        )))
                    .toList(),
              )
            : Container(),
        trailing: Text(
          '${selectedList.length}/${maxCount}',
          style: TextStyle(color: Colors.white),
        )
            .intoContainer(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: selectedList.isEmpty ? ColorConstant.CardColor : ColorConstant.BlueColor,
                ))
            .intoGestureDetector(onTap: () {
          if (selectedList.isEmpty) {
            return;
          }
          Navigator.of(context).pop(selectedList);
        }),
      ),
      body: GridView.builder(
        // cacheExtent: ScreenUtil.screenSize.height,
        controller: scrollController,
        padding: EdgeInsets.all($(12)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: $(6),
          crossAxisSpacing: $(6),
        ),
        itemBuilder: (context, index) {
          return buildItem(context, index);
        },
        itemCount: dataList.length,
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
                width: (imageSize * 3).toInt(),
                height: (imageSize * 3).toInt(),
              ),
              fit: BoxFit.cover,
            ),
            width: imageSize,
            height: imageSize,
          ),
          isBad
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
                  child: selected
                      ? Text(
                          '${(selectedList.findPosition((e) => e.id == data.id) ?? 0) + 1}',
                          style: TextStyle(color: Colors.white),
                        ).intoContainer(
                          width: $(19),
                          height: $(19),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ColorConstant.BlueColor,
                            borderRadius: BorderRadius.circular(32),
                          ))
                      : Icon(
                          Icons.check,
                          color: ColorConstant.White,
                          size: $(16),
                        ).intoContainer(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: ColorConstant.White),
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
