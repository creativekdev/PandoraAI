import 'package:cartoonizer/Widgets/visibility_holder.dart';
import 'package:cartoonizer/models/home_page_entity.dart';

import '../../Common/importFile.dart';
import '../../api/app_api.dart';
import '../../models/discovery_list_entity.dart';

typedef OnClickAll = Function(String category, List<DiscoveryListEntity>? posts, String title);
typedef OnClickItem = Function(int index, String category, List<DiscoveryListEntity>? posts, String title);

class PaiContentView extends StatefulWidget {
  const PaiContentView({Key? key, required this.height, required this.onTap, required this.onTapItem, required this.galleries}) : super(key: key);
  final double height;
  final OnClickAll onTap;
  final OnClickItem onTapItem;
  final HomePageHomepageGalleries? galleries;

  @override
  State<PaiContentView> createState() => _PaiContentViewState(socialPost: galleries?.socialPosts);
}

class _PaiContentViewState extends State<PaiContentView> with AutomaticKeepAliveClientMixin {
  _PaiContentViewState({required this.socialPost});

  ScrollController _scrollController = ScrollController(keepScrollOffset: true);
  List<DiscoveryListEntity>? socialPost;

  bool isLoading = false;
  late AppApi appApi;

  @override
  void initState() {
    super.initState();
    appApi = AppApi();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels + $(80) >= _scrollController.position.maxScrollExtent) {
        _loadNextPage();
      }
    });
  }

  Future<void> _loadNextPage() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    appApi.socialHomePost(from: socialPost?.length ?? 0, size: 10, category: widget.galleries?.categoryString ?? '').then((value) {
      setState(() {
        socialPost?.addAll(value?.data.rows ?? []);
        isLoading = false;
        // _scrollController = ScrollController(
        //   initialScrollOffset: currentPosition,
        //   keepScrollOffset: true,
        // );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.only(left: $(15), right: $(15), top: $(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TitleTextWidget(
                getTitle(widget.galleries?.title ?? ''),
                ColorConstant.White,
                FontWeight.w500,
                $(16),
                maxLines: 1,
              ).intoContainer(
                alignment: Alignment.center,
              ),
              Spacer(),
              TitleTextWidget(
                "${S.of(context).all} >",
                ColorConstant.DividerColor,
                FontWeight.w400,
                $(12),
              )
                  .intoContainer(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: $(8)),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: ColorConstant.White.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular($(10)),
                ),
              )
                  .intoGestureDetector(
                onTap: () {
                  widget.onTap(widget.galleries?.categoryString ?? '', socialPost, getTitle(widget.galleries?.title ?? ''));
                },
              )
            ],
          ),
          SizedBox(
            height: $(8),
          ),
          Container(
            height: widget.height,
            child: ListView.separated(
              physics: ClampingScrollPhysics(),
              controller: _scrollController,
              separatorBuilder: (context, index) => SizedBox(width: $(8)),
              scrollDirection: Axis.horizontal,
              itemCount: this.socialPost?.length ?? 0,
              itemBuilder: (context, index) => _Item(widget.height, this.socialPost![index]).intoGestureDetector(
                onTap: () {
                  widget.onTapItem(index, widget.galleries?.categoryString ?? '', socialPost, getTitle(widget.galleries?.title ?? ''));
                },
              ),
            ),
          ),
          SizedBox(
            height: $(12),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    appApi.unbind();
  }

  @override
  bool get wantKeepAlive => true;

  String getTitle(String title) {
    if (title == "new") {
      return S.of(context).new_category;
    }
    if (title == "facetoon") {
      return S.of(context).facetoon;
    }
    if (title == "stylemorph") {
      return S.of(context).stylemorph;
    }
    if (title == "blogging") {
      return S.of(context).blogging;
    }
    if (title == "furry") {
      return S.of(context).furry;
    }
    return "";
  }
}

class _Item extends StatelessWidget {
  _Item(this.height, this.post);

  final double height;
  final DiscoveryListEntity post;

  @override
  Widget build(BuildContext context) {
    List<DiscoveryResource> list = post.resourceList().reversed.toList();
    DiscoveryResource? resource = list.firstWhereOrNull((element) => element.type == DiscoveryResourceType.image);
    return resource == null
        ? SizedBox.shrink()
        : ClipRRect(
            borderRadius: BorderRadius.circular($(8)),
            child: VisibilityImageHolder(
              url: resource.url!,
              width: $(96),
              height: height,
            ),
          );
  }
}
