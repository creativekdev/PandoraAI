import 'package:cartoonizer/Widgets/camera/pai_camera_screen.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album_helper.dart';
import 'package:cartoonizer/Widgets/image/medium_image_provider.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:skeletons/skeletons.dart';

import '../background_picker.dart';

class BackImagePicker extends StatefulWidget {
  AppState parent;
  Function(String filePath) onPickFile;
  final BackgroundData preBackgroundData;

  BackImagePicker({
    super.key,
    required this.parent,
    required this.onPickFile,
    required this.preBackgroundData,
  });

  @override
  State<BackImagePicker> createState() => _BackImagePickerState();
}

class _BackImagePickerState extends State<BackImagePicker> with AutomaticKeepAliveClientMixin {
  AssetPathEntity? totalAlbum;
  List<AssetEntity> dataList = [];
  bool loading = false;
  int page = 0;
  int pageSize = 20;
  var scrollController = ScrollController();
  double itemSize = 0;
  BackgroundData selectedData = BackgroundData();
  bool isResetSelected = false;

  @override
  void initState() {
    super.initState();
    loading = true;
    itemSize = (ScreenUtil.screenSize.width - $(45)) / 3;
    scrollController.addListener(() {
      if (loading) {
        return;
      }
      if (dataList.length < pageSize) {
        return;
      }
      if (scrollController.position.pixels > scrollController.position.maxScrollExtent - 20) {
        loadMorePage();
      }
    });
    PickAlbumHelper.getTotalAlbum().then((value) {
      totalAlbum = value;
      if (totalAlbum == null) {
        setState(() {
          loading = false;
        });
      } else {
        loadFirstPage();
      }
    });
  }

  loadFirstPage() async {
    setState(() {
      loading = true;
    });
    totalAlbum!.getAssetListPaged(page: 0, size: pageSize).then((value) {
      setState(() {
        loading = false;
        page = 0;
        dataList = value;
      });
    });
  }

  loadMorePage() async {
    setState(() {
      loading = true;
    });
    totalAlbum!.getAssetListPaged(page: page + 1, size: pageSize).then((value) {
      setState(() {
        loading = false;
        if (value.isNotEmpty) {
          page++;
          dataList.addAll(value);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return loading && dataList.isEmpty
        ? SkeletonListView(
            item: Row(
              children: [
                Expanded(
                  child: SkeletonAvatar(
                    style: SkeletonAvatarStyle(width: itemSize, height: itemSize),
                  ),
                ),
                SizedBox(width: $(10)),
                Expanded(
                  child: SkeletonAvatar(
                    style: SkeletonAvatarStyle(width: itemSize, height: itemSize),
                  ),
                ),
                SizedBox(width: $(10)),
                Expanded(
                  child: SkeletonAvatar(
                    style: SkeletonAvatarStyle(width: itemSize, height: itemSize),
                  ),
                ),
              ],
            ).intoContainer(margin: EdgeInsets.only(bottom: $(10))),
          )
        : GridView.builder(
            controller: scrollController,
            itemCount: dataList.length + 1,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.only(left: $(15), top: 0, right: $(15), bottom: ScreenUtil.getBottomPadding(context)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              mainAxisSpacing: $(5),
              crossAxisSpacing: $(5),
            ),
            itemBuilder: (context, index) {
              int pos = index - 1;
              if (index == 0) {
                return Image.asset(
                  Images.ic_choose_camera,
                  color: ColorConstant.White,
                )
                    .intoContainer(
                  color: ColorConstant.LineColor,
                  padding: EdgeInsets.symmetric(vertical: $(24)),
                )
                    .intoGestureDetector(onTap: () {
                  PAICamera.takePhoto(context).then((value) {
                    if (value != null) {
                      widget.onPickFile.call(value.xFile.path);
                    }
                  });
                });
              } else {
                return buildItem(context, pos);
              }
            });
  }

  Future<bool> getMediaPath(AssetEntity entity) async {
    if (widget.preBackgroundData.filePath == null) return false;
    if (isResetSelected == true) {
      return false;
    }
    var file = await entity.originFile;
    var path = await ImageUtils.onImagePick(file!.path, AppDelegate().getManager<CacheManager>().storageOperator.imageDir.path);
    // selectedData = widget.preBackgroundData;
    if (selectedData.filePath == null) {
      if (path.contains(widget.preBackgroundData.filePath!)) {
        selectedData.filePath = widget.preBackgroundData.filePath;
        isResetSelected = true;
        return true;
      }
    } else {
      if (path.contains(selectedData.filePath!)) {
        isResetSelected = true;
        return true;
      }
    }
    return false;
  }

  Widget buildItem(BuildContext context, int index) {
    var media = dataList[index];
    return FutureBuilder(
        future: getMediaPath(media),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Image(
              image: MediumImage(
                media,
                width: 128,
                height: 128,
                failedImageAssets: Images.ic_netimage_failed,
              ),
              width: itemSize,
              height: itemSize,
              fit: BoxFit.cover,
            ).intoGestureDetector(onTap: () {
              widget.parent.showLoading().whenComplete(() async {
                var file = await media.originFile;
                var path = await ImageUtils.onImagePick(file!.path, AppDelegate().getManager<CacheManager>().storageOperator.imageDir.path);
                widget.parent.hideLoading().whenComplete(() {
                  widget.onPickFile.call(path);
                });
              });
            });
          }
          return Stack(
            children: [
              Image(
                image: MediumImage(
                  media,
                  width: 128,
                  height: 128,
                  failedImageAssets: Images.ic_netimage_failed,
                ),
                width: itemSize,
                height: itemSize,
                fit: BoxFit.cover,
              ),
              if (snapshot.data == true)
                Container(
                  color: Color(0x55000000),
                  width: itemSize,
                  height: itemSize,
                  child: Image.asset(
                    Images.ic_metagram_yes,
                    width: $(22),
                  ).intoCenter(),
                ),
            ],
          ).intoGestureDetector(onTap: () {
            widget.parent.showLoading().whenComplete(() async {
              var file = await media.originFile;
              var path = await ImageUtils.onImagePick(file!.path, AppDelegate().getManager<CacheManager>().storageOperator.imageDir.path);
              selectedData!.filePath = path;
              isResetSelected = false;
              widget.parent.hideLoading().whenComplete(() {
                widget.onPickFile.call(path);
              });
            });
          });
        });
  }

  @override
  bool get wantKeepAlive => true;
}
