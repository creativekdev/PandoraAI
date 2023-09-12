import 'package:cartoonizer/widgets/visibility_holder.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';

import '../../common/importFile.dart';
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
        padding: EdgeInsets.only(left: $(15), right: $(15), top: $(12)),
        child: Wrap(
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
                .toList()));
  }
}

class SliverItem extends StatelessWidget {
  final HomePageHomepageTools entity;

  const SliverItem({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    double width = (ScreenUtil.screenSize.width - $(69)) / 4 - 1;
    var title = entity.category.title();
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular($(8)),
          child: VisibilityImageHolder(
            url: entity.url,
            height: width,
            width: width,
          ),
        ),
        TitleTextWidget(
          title.isEmpty ? entity.categoryString! : title,
          ColorConstant.DividerColor,
          FontWeight.w400,
          $(10),
          maxLines: 1,
        ).intoContainer(
          // width: width,
          padding: EdgeInsets.only(top: $(8), bottom: $(8)),
        )
      ],
    );
  }
}
