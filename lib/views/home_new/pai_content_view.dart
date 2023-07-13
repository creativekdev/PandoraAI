import 'package:cartoonizer/models/home_page_entity.dart';
import 'package:cartoonizer/utils/string_ex.dart';

import '../../Common/importFile.dart';
import '../../Widgets/cacheImage/cached_network_image_utils.dart';
import '../../api/cartoonizer_api.dart';
import '../../models/discovery_list_entity.dart';

typedef OnClickAll = Function(String category, List<DiscoveryListEntity>? posts);
typedef OnClickItem = Function(int index, String category, List<DiscoveryListEntity>? posts);

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
  late CartoonizerApi cartoonizerApi;

  @override
  void initState() {
    super.initState();
    cartoonizerApi = CartoonizerApi();
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
    double currentPosition = _scrollController.position.pixels;
    setState(() {
      isLoading = true;
    });
    cartoonizerApi.socialHomePost(from: socialPost?.length ?? 0, size: 10, category: widget.galleries?.categoryString ?? '').then((value) {
      setState(() {
        socialPost?.addAll(value?.data.rows ?? []);
        isLoading = false;
        _scrollController = ScrollController(
          initialScrollOffset: currentPosition,
          keepScrollOffset: true,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: $(15), right: $(15), top: $(16)),
      child: Column(
        children: [
          Row(
            children: [
              TitleTextWidget(
                (widget.galleries?.title ?? '').toUpperCaseFirst,
                ColorConstant.White,
                FontWeight.w500,
                $(17),
              ),
              Spacer(),
              TitleTextWidget(
                "${S.of(context).all} >",
                ColorConstant.DividerColor,
                FontWeight.w400,
                $(12),
              )
                  .intoContainer(
                height: $(20),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: $(8)),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: ColorConstant.White.withOpacity(0.1),
                  ),
                  borderRadius: BorderRadius.circular($(10)),
                ),
              )
                  .intoGestureDetector(
                onTap: () {
                  widget.onTap(widget.galleries?.categoryString ?? '', socialPost);
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
                  widget.onTapItem(index, widget.galleries?.categoryString ?? '', socialPost);
                },
              ),
            ),
          ),
          SizedBox(
            height: $(16),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    cartoonizerApi.unbind();
  }

  @override
  bool get wantKeepAlive => true;
}

class _Item extends StatelessWidget {
  _Item(this.height, this.post);

  final double height;
  final DiscoveryListEntity post;

  @override
  Widget build(BuildContext context) {
    List<DiscoveryResource> list = post.resourceList();
    DiscoveryResource? resource = list.firstWhereOrNull((element) => element.type == DiscoveryResourceType.image);
    return resource == null
        ? SizedBox.shrink()
        : ClipRRect(
            borderRadius: BorderRadius.circular($(8)),
            child: CachedNetworkImageUtils.custom(
              fit: BoxFit.cover,
              useOld: false,
              height: height,
              width: $(96),
              context: context,
              imageUrl: resource.url!,
            ),
          );
  }
}
