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
    final finalList = list?.where((t) => t.category != HomeCardType.nothing && t.category != HomeCardType.UNDEFINED).toList();
    return Container(
        padding: EdgeInsets.only(left: $(15), right: $(15), top: $(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleTextWidget(
              'Tools',
              ColorConstant.White,
              FontWeight.w500,
              $(17),
              align: TextAlign.left,
            ).intoContainer(
                padding: EdgeInsets.only(
              bottom: $(8),
            )),
            Wrap(
                spacing: $(12),
                runSpacing: $(12),
                children: finalList!
                    .map(
                      (e) => SliverItem(
                        entity: e,
                      ).intoGestureDetector(onTap: () {
                        onClickItem(e);
                      }),
                    )
                    .toList()),
          ],
        ));
  }
}

class SliverItem extends StatelessWidget {
  final HomePageHomepageTools entity;

  const SliverItem({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    double width = (ScreenUtil.screenSize.width - $(68)) / 4;
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
          ColorConstant.DividerColor,
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
