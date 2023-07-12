import 'package:cartoonizer/models/enums/home_card_type.dart';

import '../../Common/importFile.dart';
import '../../Widgets/cacheImage/cached_network_image_utils.dart';
import '../../models/home_page_entity.dart';

typedef OnClickItem = Function(HomePageHomepageTools data);

class PaiSliverView extends StatelessWidget {
  const PaiSliverView({Key? key, required this.list, required this.onClickItem}) : super(key: key);
  final List<HomePageHomepageTools>? list;
  final OnClickItem onClickItem;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: $(14)),
        child: Wrap(
            spacing: $(8),
            runSpacing: $(8),
            children: list!
                .map(
                  (e) => SliverItem(
                    entity: e,
                  ).intoGestureDetector(onTap: () {
                    onClickItem(e);
                  }),
                )
                .toList()));
  }
}

class SliverItem extends StatelessWidget {
  final HomePageHomepageTools entity;

  const SliverItem({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    double width = (ScreenUtil.screenSize.width - $(54)) / 4;
    var title = entity.category.title();
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular($(8)),
          child: CachedNetworkImageUtils.custom(
            fit: BoxFit.cover,
            useOld: false,
            height: width,
            width: width,
            context: context,
            imageUrl: entity.url,
          ),
        ),
        TitleTextWidget(
          title.isEmpty ? entity.categoryString! : title,
          ColorConstant.White,
          FontWeight.w400,
          $(12),
          maxLines: 1,
        ).intoContainer(
          width: width,
          padding: EdgeInsets.only(top: $(8), bottom: $(8)),
        )
      ],
    );
  }
}
