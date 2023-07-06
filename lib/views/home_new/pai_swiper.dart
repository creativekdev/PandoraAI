import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import '../../Common/importFile.dart';
import '../../Widgets/cacheImage/cached_network_image_utils.dart';
import '../../models/home_page_entity.dart';

typedef OnClickItem = Function(int index, HomePageHomepageTools data);

class PaiSwiper extends StatelessWidget {
  const PaiSwiper({Key? key, required this.entity, required this.onClickItem}) : super(key: key);
  final List<HomePageHomepageTools>? entity;
  final OnClickItem onClickItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: $(200),
      padding: EdgeInsets.symmetric(horizontal: $(15)),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          HomePageHomepageTools data = entity![index];
          return UnconstrainedBox(
            child: ClipRRect(
              borderRadius: BorderRadius.circular($(8)),
              child: CachedNetworkImageUtils.custom(
                fit: BoxFit.cover,
                useOld: false,
                height: $(150),
                width: ScreenUtil.screenSize.width - $(30),
                context: context,
                imageUrl: data.url,
              ),
            ),
          );
        },
        onTap: (index) {
          HomePageHomepageTools data = entity![index];
          onClickItem(index, data);
        },
        itemHeight: $(150),
        itemCount: entity?.length ?? 0,
        autoplay: true,
        pagination: SwiperPagination(
            builder: DotSwiperPaginationBuilder(
          color: Colors.grey,
          activeColor: Colors.white,
          size: $(8),
          activeSize: $(8),
        )),
      ),
    );
  }
}
