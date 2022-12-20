import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:photo_gallery/photo_gallery.dart';

class PickAlbumScreen {
  static Future<List<Medium>?> pickImage(
    BuildContext context, {
    List<Medium>? selectedList,
    int count = 20,
    bool switchAlbum = false,
  }) =>
      Navigator.of(context).push<List<Medium>>(MaterialPageRoute(
        builder: (context) => _PickAlbumScreen(
          switchAlbum: switchAlbum,
          selectedList: selectedList ?? [],
          maxCount: count,
        ),
      ));
}

class _PickAlbumScreen extends StatefulWidget {
  bool switchAlbum;
  List<Medium> selectedList;
  int maxCount;

  _PickAlbumScreen({
    Key? key,
    required this.switchAlbum,
    required this.selectedList,
    required this.maxCount,
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
  ScrollController scrollController = ScrollController();
  late bool switchAlbum;
  late List<Medium> selectedList;
  late int maxCount;

  late double imageSize;

  _PickAlbumScreenState() : super(canCancelOnLoading: false);

  @override
  void initState() {
    super.initState();
    imageSize = (ScreenUtil.screenSize.width - $(48)) / 3;
    maxCount = widget.maxCount;
    selectedList = [...widget.selectedList];
    switchAlbum = widget.switchAlbum;
    scrollController.addListener(() {
      if (_isRequesting) {
        return;
      }
      if (scrollController.position.pixels > scrollController.position.maxScrollExtent - 20) {
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
    selectAlbum!.listMedia(skip: 0, take: pageSize).then((value) {
      setState(() {
        page = 0;
        dataList = value.items;
      });
      _isRequesting = false;
    });
  }

  void loadMore() {
    _isRequesting = true;
    selectAlbum!.listMedia(skip: (page + 1) * pageSize, take: pageSize).then((value) {
      if (value.items.isNotEmpty) {
        setState(() {
          page++;
          dataList.addAll(value.items);
        });
      }
      _isRequesting = false;
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
    bool selected = selectedList.exist((t) => t.id == data.id);
    return Container(
      child: Stack(
        children: [
          SizedBox(
            child: _LoadFileImage(
              medium: data,
            ),
            width: imageSize,
            height: imageSize,
          ),
          Positioned(
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

class _LoadFileImage extends StatefulWidget {
  Medium medium;

  _LoadFileImage({
    Key? key,
    required this.medium,
  }) : super(key: key);

  @override
  State<_LoadFileImage> createState() => _LoadFileImageState();
}

class _LoadFileImageState extends State<_LoadFileImage> {
  late Medium medium;
  List<int>? data;

  @override
  void initState() {
    super.initState();
    medium = widget.medium;
    loadData();
  }

  loadData() => medium.getThumbnail(width: 256, height: 256, highQuality: true).then((value) {
        if (mounted) {
          setState(() {
            data = value;
          });
        }
      });

  @override
  void didUpdateWidget(covariant _LoadFileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (medium.id != widget.medium.id) {
      medium = widget.medium;
      loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return data == null
        ? CircularProgressIndicator().intoContainer(width: $(25), height: $(25)).intoCenter()
        : Image(
            image: MemoryImage(Uint8List.fromList(data!)),
            fit: BoxFit.cover,
          );
  }
}
