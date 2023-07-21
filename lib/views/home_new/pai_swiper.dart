import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import '../../Common/importFile.dart';
import '../../models/discovery_list_entity.dart';

typedef OnClickItem = Function(int index, DiscoveryListEntity data);

class PaiSwiper extends StatelessWidget {
  const PaiSwiper({Key? key, required this.entity, required this.onClickItem}) : super(key: key);
  final List<DiscoveryListEntity>? entity;
  final OnClickItem onClickItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (ScreenUtil.screenSize.width - $(30)) * 0.75 + $(50),
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
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: resource.url!,
                      height: (ScreenUtil.screenSize.width - $(30)) * 0.75,
                      width: ScreenUtil.screenSize.width - $(30),
                    ),
                    // child: CachedNetworkImageUtils.custom(
                    //   fit: BoxFit.cover,
                    //   fadeOutDuration: Duration(milliseconds: 10),
                    //   fadeInDuration: Duration(milliseconds: 10),
                    //   useOld: false,
                    //   height: (ScreenUtil.screenSize.width - $(30)) * 0.75,
                    //   width: ScreenUtil.screenSize.width - $(30),
                    //   context: context,
                    //   imageUrl: resource.url!,
                    // ),
                  ),
                );
        },
        onTap: (index) {
          DiscoveryListEntity data = entity![index];
          onClickItem(index, data);
        },
        itemHeight: (ScreenUtil.screenSize.width - $(30)) * 0.75,
        itemCount: entity?.length ?? 0,
        autoplay: false,
        pagination: SwiperPagination(
            builder: DotSwiperPaginationBuilder(
          color: Colors.grey,
          activeColor: Colors.white,
          size: $(6),
          activeSize: $(6),
        )),
      ),
    );
  }
}
