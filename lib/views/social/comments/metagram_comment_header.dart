import 'package:cartoonizer/widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:skeletons/skeletons.dart';

class MetagramCommentHeader extends StatefulWidget {
  MetagramItemEntity data;
  bool hasEmpty;

  MetagramCommentHeader({
    Key? key,
    required this.data,
    required this.hasEmpty,
  }) : super(key: key);

  @override
  State<MetagramCommentHeader> createState() => _MetagramCommentHeaderState();
}

class _MetagramCommentHeaderState extends State<MetagramCommentHeader> {
  late MetagramItemEntity data;

  late List<DiscoveryResource> resourceList;
  late List<List<DiscoveryResource>> items;
  double maxHeight = 0;
  int currentIndex = 0;
  double imageWidth = 0;
  late bool hasEmpty;

  @override
  void initState() {
    super.initState();
    imageWidth = ScreenUtil.screenSize.width - $(32);
    initData();
  }

  @override
  void didUpdateWidget(covariant MetagramCommentHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    initData();
  }

  initData() {
    hasEmpty = widget.hasEmpty;
    data = widget.data;
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: $(8)),
        buildItems(context),
        SizedBox(height: $(8)),
        items.length > 1
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
        Text(
          'No comments yet',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: $(15)),
        )
            .intoCenter()
            .intoContainer(
              height: $(300),
              width: ScreenUtil.screenSize.width,
            )
            .visibility(visible: hasEmpty),
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
      ).intoContainer(height: maxHeight, width: ScreenUtil.screenSize.width);
    }
  }

  Widget buildOneImage(BuildContext context, List<DiscoveryResource> items, {bool needListenSize = false}) {
    var child = Row(
      children: [
        CachedNetworkImageUtils.custom(
            useOld: false,
            context: context,
            imageUrl: items.last.url!,
            fit: BoxFit.contain,
            width: imageWidth / 2,
            placeholder: (context, url) {
              return SkeletonAvatar(
                style: SkeletonAvatarStyle(width: imageWidth / 2, height: maxHeight == 0 ? $(300) : maxHeight),
              );
            }),
        SizedBox(width: $(2)),
        CachedNetworkImageUtils.custom(
            context: context,
            useOld: false,
            imageUrl: items.first.url!,
            fit: BoxFit.contain,
            width: imageWidth / 2,
            placeholder: (context, url) {
              return SkeletonAvatar(
                style: SkeletonAvatarStyle(width: imageWidth / 2, height: maxHeight == 0 ? $(300) : maxHeight),
              );
            }),
      ],
    ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)));
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
