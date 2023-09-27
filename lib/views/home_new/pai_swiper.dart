import 'package:cartoonizer/widgets/visibility_holder.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import '../../common/importFile.dart';
import '../../models/discovery_list_entity.dart';

typedef OnClickItem = Function(int index, DiscoveryListEntity data);

class PaiSwiper extends StatelessWidget {
  const PaiSwiper({Key? key, required this.entity, required this.onClickItem}) : super(key: key);
  final List<DiscoveryListEntity>? entity;
  final OnClickItem onClickItem;

  @override
  Widget build(BuildContext context) {
    var height = (ScreenUtil.screenSize.width - 30.dp) * 0.75 + 15.dp;
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: $(15)),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          List<DiscoveryResource> list = entity![index].resourceList();
          DiscoveryResource? resource = list.firstWhereOrNull((element) => element.type == DiscoveryResourceType.image);
          return resource == null
              ? SizedBox.shrink()
              : UnconstrainedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular($(8)),
                    child: VisibilityImageHolder(
                      url: resource.url!,
                      height: height,
                      width: ScreenUtil.screenSize.width - $(30),
                    ),
                  ),
                );
        },
        onTap: (index) {
          DiscoveryListEntity data = entity![index];
          onClickItem(index, data);
        },
        itemHeight: height,
        itemCount: entity?.length ?? 0,
        autoplay: false,
        pagination: SwiperPagination(
            builder: DotSwiperPaginationBuilder2(
          color: Colors.grey,
          activeColor: Colors.white,
          size: $(6),
          activeSize: $(6),
          padding: EdgeInsets.symmetric(horizontal: 3.dp),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.dp), color: Colors.black.withOpacity(0.3)),
        )),
      ),
    );
  }
}

class DotSwiperPaginationBuilder2 extends SwiperPlugin {
  ///color when current index,if set null , will be Theme.of(context).primaryColor
  final Color? activeColor;

  ///,if set null , will be Theme.of(context).scaffoldBackgroundColor
  final Color? color;

  ///Size of the dot when activate
  final double activeSize;

  ///Size of the dot
  final double size;

  /// Space between dots
  final double space;

  final Key? key;
  final Decoration? decoration;
  final EdgeInsets padding;

  const DotSwiperPaginationBuilder2({
    this.activeColor,
    this.color,
    this.key,
    this.size = 10.0,
    this.activeSize = 10.0,
    this.space = 3.0,
    this.decoration,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    if (config.itemCount == 1) {
      return SizedBox.shrink();
    }
    if (config.itemCount > 20) {
      print("The itemCount is too big, we suggest use FractionPaginationBuilder instead of DotSwiperPaginationBuilder in this sitituation");
    }
    Color? activeColor = this.activeColor;
    Color? color = this.color;

    if (activeColor == null || color == null) {
      ThemeData themeData = Theme.of(context);
      activeColor = this.activeColor ?? themeData.primaryColor;
      color = this.color ?? themeData.scaffoldBackgroundColor;
    }

    if (config.indicatorLayout != PageIndicatorLayout.NONE && config.layout == SwiperLayout.DEFAULT) {
      return new PageIndicator(
        count: config.itemCount,
        controller: config.pageController,
        layout: config.indicatorLayout,
        size: size,
        activeColor: activeColor,
        color: color,
        space: space,
      ).intoContainer(decoration: decoration, padding: padding);
    }

    List<Widget> list = [];

    int itemCount = config.itemCount;
    int activeIndex = config.activeIndex;

    for (int i = 0; i < itemCount; ++i) {
      bool active = i == activeIndex;
      list.add(Container(
        key: Key("pagination_$i"),
        margin: EdgeInsets.all(space),
        child: ClipOval(
          child: Container(
            color: active ? activeColor : color,
            width: active ? activeSize : size,
            height: active ? activeSize : size,
          ),
        ),
      ));
    }

    if (config.scrollDirection == Axis.vertical) {
      return new Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      ).intoContainer(decoration: decoration, padding: padding);
    } else {
      return new Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: list,
      ).intoContainer(decoration: decoration, padding: padding);
    }
  }
}
