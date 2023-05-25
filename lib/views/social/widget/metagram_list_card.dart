import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_detail_card.dart';
import 'package:common_utils/common_utils.dart';
import 'package:like_button/like_button.dart';
import 'package:skeletons/skeletons.dart';

class MetagramListCard extends StatefulWidget {
  MetagramItemEntity data;
  Function(List<List<DiscoveryResource>> items, int index) onEditTap;
  Function(List<DiscoveryResource> items) onDownloadTap;
  Function(List<DiscoveryResource> items) onShareOutTap;
  Function() onCommentsTap;
  OnLikeTap onLikeTap;
  bool liked;

  MetagramListCard({
    super.key,
    required this.data,
    required this.onEditTap,
    required this.onDownloadTap,
    required this.onShareOutTap,
    required this.onLikeTap,
    required this.liked,
    required this.onCommentsTap,
  });

  @override
  MetagramListState createState() {
    return MetagramListState();
  }
}

class MetagramListState extends State<MetagramListCard> {
  late MetagramItemEntity data;
  late Function(List<List<DiscoveryResource>> items, int index) onEditTap;
  late Function(List<DiscoveryResource> items) onDownloadTap;
  late Function(List<DiscoveryResource> items) onShareOutTap;
  late Function() onCommentsTap;
  late OnLikeTap onLikeTap;
  late bool liked;
  late List<DiscoveryResource> resourceList;
  late List<List<DiscoveryResource>> items;

  double maxHeight = 0;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void didUpdateWidget(covariant MetagramListCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    initData();
  }

  initData() {
    data = widget.data;
    onEditTap = widget.onEditTap;
    onDownloadTap = widget.onDownloadTap;
    onShareOutTap = widget.onShareOutTap;
    onLikeTap = widget.onLikeTap;
    onCommentsTap = widget.onCommentsTap;
    liked = widget.liked;
    resourceList = data.resourceList();
    items = [];
    for (var value in resourceList) {
      List<DiscoveryResource> l;
      if (items.isEmpty || items.last.length == 2) {
        l = [];
        l.add(value);
        items.add(l);
      } else {
        items.last.add(value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (resourceList.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildItems(context),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  buildComments(context).intoGestureDetector(onTap: () {
                    onCommentsTap.call();
                  }),
                  SizedBox(width: $(12)),
                  LikeButton(
                    size: $(26),
                    countPostion: CountPostion.bottom,
                    circleColor: CircleColor(
                      start: Color(0xfffc2a2a),
                      end: Color(0xffc30000),
                    ),
                    bubblesColor: BubblesColor(
                      dotPrimaryColor: Color(0xfffc2a2a),
                      dotSecondaryColor: Color(0xffc30000),
                    ),
                    isLiked: liked,
                    likeBuilder: (bool isLiked) {
                      return Image.asset(
                        isLiked ? Images.ic_discovery_liked : Images.ic_discovery_like,
                        width: $(26),
                        color: isLiked ? Colors.red : Colors.white,
                      );
                    },
                    likeCount: data.likes,
                    onTap: (liked) async => await onLikeTap.call(liked),
                    countBuilder: (int? count, bool isLiked, String text) {
                      count ??= 0;
                      return Text(
                        count.socialize,
                        style: TextStyle(color: Colors.white, fontSize: $(12)),
                      );
                    },
                  ),
                  SizedBox(width: $(12)),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
            items.length > 1
                ? Row(
                    children: items.transfer(
                      (e, index) => Container(
                        height: $(6),
                        width: $(6),
                        margin: EdgeInsets.symmetric(horizontal: $(4)),
                        decoration: BoxDecoration(color: currentIndex == index ? Colors.white : Colors.grey, borderRadius: BorderRadius.circular($(6))),
                      ),
                    ),
                  ).intoContainer(margin: EdgeInsets.only(top: $(8)))
                : Container(),
            Expanded(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: $(12)),
                Image.asset(Images.ic_metagram_shareout, width: $(26)).intoGestureDetector(onTap: () {
                  if (items.isEmpty) {
                    return;
                  }
                  onShareOutTap.call(items[currentIndex]);
                }),
                SizedBox(width: $(12)),
                Image.asset(Images.ic_metagram_download, width: $(26)).intoGestureDetector(onTap: () {
                  if (items.isEmpty) {
                    return;
                  }
                  onDownloadTap.call(items[currentIndex]);
                }),
              ],
            )),
          ],
        ).intoContainer(padding: EdgeInsets.only(top: $(12), left: $(12), right: $(12), bottom: $(6))),
        TitleTextWidget(data.text ?? '', Colors.white, FontWeight.normal, $(15))
            .intoContainer(padding: EdgeInsets.symmetric(horizontal: $(12)))
            .offstage(offstage: TextUtil.isEmpty(data.text)),
        OutlineWidget(
          radius: $(8),
          strokeWidth: $(1.5),
          gradient: LinearGradient(
            colors: [
              Color(0xFFEC5DD8),
              Color(0xFF7F97F3),
              Color(0xFF04F1F9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Text(
            S.of(context).generate_again,
            style: TextStyle(
              color: ColorConstant.White,
              fontSize: $(13),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
          ).intoContainer(
            height: $(30),
            width: $(120),
            alignment: Alignment.center,
          ),
        ).intoMaterial(color: Color(0xff222222), borderRadius: BorderRadius.circular($(8))).intoGestureDetector(onTap: () {
          onEditTap.call(items, currentIndex);
        }).intoContainer(
          margin: EdgeInsets.symmetric(horizontal: $(12), vertical: $(12)),
        ),
      ],
    );
  }

  Widget buildComments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          Images.ic_metagram_comment,
          width: $(26),
        ),
        TitleTextWidget(data.comments.socialize, Colors.white, FontWeight.w400, $(12)),
      ],
    );
  }

  Widget buildItems(BuildContext context) {
    if (items.length == 1) {
      return buildOneImage(context, items.first);
    } else {
      return PageView(
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: items.map((e) => buildOneImage(context, e, needListenSize: true)).toList(),
      ).intoContainer(height: maxHeight, width: double.maxFinite);
    }
  }

  Widget buildOneImage(BuildContext context, List<DiscoveryResource> items, {bool needListenSize = false}) {
    var child = Stack(
      children: [
        CachedNetworkImageUtils.custom(
            context: context,
            useOld: false,
            imageUrl: items.first.url!,
            fit: BoxFit.cover,
            placeholder: (context, url) {
              return SkeletonAvatar(
                style: SkeletonAvatarStyle(width: ScreenUtil.screenSize.width, height: maxHeight == 0 ? ScreenUtil.screenSize.width : maxHeight),
              );
            }),
        Positioned(
          child: ClipRRect(
                  child: CachedNetworkImageUtils.custom(
                    useOld: false,
                    context: context,
                    imageUrl: items.last.url!,
                    fit: BoxFit.cover,
                    width: $(70),
                    height: $(70),
                  ),
                  borderRadius: BorderRadius.circular($(6)))
              .intoContainer(padding: EdgeInsets.all($(2)))
              .intoMaterial(borderRadius: BorderRadius.circular($(8)), color: Colors.white, elevation: 4),
          top: $(15),
          left: $(15),
        ),
      ],
    );
    if (!needListenSize) {
      return child;
    }
    return SingleChildScrollView(
      child: child.listenSizeChanged(onSizeChanged: (size) {
        if (!mounted) {
          return;
        }
        if (size.height > maxHeight) {
          setState(() {
            maxHeight = size.height;
          });
        }
      }),
    );
  }
}
