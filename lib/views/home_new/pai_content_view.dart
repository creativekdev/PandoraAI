import 'package:cartoonizer/models/home_page_entity.dart';
import 'package:cartoonizer/widgets/visibility_holder.dart';

import '../../api/app_api.dart';
import '../../common/importFile.dart';
import '../../models/discovery_list_entity.dart';
import '../../models/home_post_entity.dart';

typedef OnClickAll = Function(String category, List<DiscoveryListEntity>? posts, String title);
typedef OnClickItem = Function(int index, String category, List<DiscoveryListEntity>? posts, String title);

class PaiContentView extends StatefulWidget {
  const PaiContentView({
    Key? key,
    required this.height,
    required this.onTap,
    required this.onTapItem,
    required this.data,
    required this.title,
  }) : super(key: key);
  final double height;
  final OnClickAll onTap;
  final OnClickItem onTapItem;
  final String title;
  final HomeItemEntity data;

  @override
  State<PaiContentView> createState() => _PaiContentViewState();
}

class _PaiContentViewState extends State<PaiContentView> with AutomaticKeepAliveClientMixin {
  late HomeItemEntity data;

  ScrollController _scrollController = ScrollController(keepScrollOffset: true);
  List<DiscoveryListEntity>? socialPost;
  int postsLength = 0;

  bool isLoading = false;
  late AppApi appApi;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    socialPost = data.getDataList<DiscoveryListEntity>();
    appApi = AppApi();
    postsLength = data.records;
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

    HomePostEntity? homePostEntity = await loadData(socialPost?.length ?? 0, 10);
    if (postsLength != homePostEntity?.data.records) {
      homePostEntity = await loadData(0, homePostEntity?.data.records ?? 0);
      setState(() {
        postsLength = homePostEntity?.data.records ?? 0;
        socialPost = homePostEntity?.data.rows ?? [];
        widget.data.value = socialPost?.map((e) => e.toJson()).toList();
        data = widget.data;
        isLoading = false;
      });
    } else {
      setState(() {
        socialPost?.addAll(homePostEntity?.data.rows ?? []);
        isLoading = false;
      });
    }
  }

  Future<HomePostEntity?> loadData(int from, int size) async {
    return await appApi.socialHomePost(from: from, size: size, category: data.key ?? '');
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
                widget.title,
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
                  widget.onTap(data.key ?? '', socialPost, widget.title);
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
                  widget.onTapItem(index, data.key ?? '', socialPost, widget.title);
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
