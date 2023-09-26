import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/widgets/image/sync_download_image.dart';
import 'package:cartoonizer/widgets/search_bar.dart' as search;
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/back_pick_template_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:skeletons/skeletons.dart';

class BackTemplatePicker extends StatefulWidget {
  double imageRatio;
  AppState parent;
  Function(String filePath) onPickFile;

  BackTemplatePicker({
    super.key,
    required this.imageRatio,
    required this.parent,
    required this.onPickFile,
  });

  @override
  State<BackTemplatePicker> createState() => _BackTemplatePickerState();
}

class _BackTemplatePickerState extends State<BackTemplatePicker> with AutomaticKeepAliveClientMixin {
  late AppApi api;
  late double imageRatio;
  List<BackPickTemplateEntity> dataList = [];

  int pageSize = 10;
  bool loading = true;
  double itemWidth = 0;
  double itemHeight = 0;

  var scrollController = ScrollController();
  TextEditingController keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    imageRatio = widget.imageRatio;
    api = AppApi().bindState(this);
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
    itemWidth = (ScreenUtil.screenSize.width - $(42)) / 2;
    itemHeight = itemWidth / imageRatio;
    delay(() {
      loadFirstPage();
    });
  }

  loadFirstPage() {
    setState(() {
      loading = true;
    });
    api.listBackgroundImages(from: 0, size: pageSize, keyword: keywordController.text.trim()).then((value) {
      if (value != null) {
        dataList = value;
      }
      setState(() {
        loading = false;
      });
    });
  }

  loadMorePage() {
    setState(() {
      loading = true;
    });
    api.listBackgroundImages(from: dataList.length, size: pageSize, keyword: keywordController.text.trim()).then((value) {
      if (value != null) {
        dataList.addAll(value);
      }
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    api.unbind();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        search.SearchBar(
          controller: keywordController,
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          onStartSearch: () {
            loadFirstPage();
          },
          onSearchClear: () {
            loadFirstPage();
          },
        ).intoContainer(
            padding: EdgeInsets.only(left: $(15)),
            height: $(44),
            margin: EdgeInsets.only(left: $(15), right: $(15), bottom: $(10)),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular($(32)),
            )),
        Expanded(
            child: loading && dataList.isEmpty
                ? SkeletonListView(
                    item: Row(
                      children: [
                        Expanded(
                          child: SkeletonAvatar(
                            style: SkeletonAvatarStyle(width: itemWidth, height: itemHeight),
                          ),
                        ),
                        SizedBox(width: $(12)),
                        Expanded(
                          child: SkeletonAvatar(
                            style: SkeletonAvatarStyle(width: itemWidth, height: itemHeight),
                          ),
                        ),
                      ],
                    ).intoContainer(margin: EdgeInsets.only(bottom: $(10))),
                  )
                : GridView.builder(
                    controller: scrollController,
                    itemCount: dataList.length,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.only(left: $(15), top: 0, right: $(15), bottom: ScreenUtil.getBottomPadding()),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: imageRatio,
                      mainAxisSpacing: $(10),
                      crossAxisSpacing: $(10),
                    ),
                    itemBuilder: (context, index) {
                      var file = dataList[index].s3Files;
                      return CachedNetworkImageUtils.custom(
                        context: context,
                        imageUrl: file.thumbnail!,
                        width: itemWidth,
                        height: itemHeight,
                        fit: BoxFit.cover,
                      ).intoGestureDetector(onTap: () {
                        widget.parent.showLoading().whenComplete(() {
                          SyncDownloadImage(url: file.thumbnailLarge!, type: getFileType(file.thumbnailLarge!)).getImage().then((value) {
                            widget.parent.hideLoading();
                            if (value != null) {
                              widget.onPickFile.call(value.path);
                            } else {
                              CommonExtension().showToast(S.of(context).commonFailedToast);
                            }
                          }).onError((error, stackTrace) {
                            widget.parent.hideLoading();
                          });
                        });
                      });
                    })),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
