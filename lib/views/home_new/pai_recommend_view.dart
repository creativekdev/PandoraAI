import 'package:cartoonizer/widgets/visibility_holder.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';

import '../../common/importFile.dart';
import '../../models/home_page_entity.dart';

typedef OnClickItem = Function(HomePageHomepageTools data);

class PaiRecommendView extends StatelessWidget {
  const PaiRecommendView({Key? key, required this.list, required this.onClickItem}) : super(key: key);
  final List<HomePageHomepageTools>? list;
  final OnClickItem onClickItem;

  @override
  Widget build(BuildContext context) {
    final finalList = list?.where((t) => t.category != HomeCardType.nothing && t.category != HomeCardType.UNDEFINED).toList();
    if (finalList == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.only(left: $(15), right: $(15), top: $(12)),
      child: Wrap(
        spacing: $(8),
        runSpacing: $(8),
        children: finalList!
            .map(
              (e) => RecommendItem(
                e,
              ).intoGestureDetector(onTap: () {
                onClickItem(e);
              }),
            )
            .toList(),
      ),
    );
  }
}

class RecommendItem extends StatelessWidget {
  RecommendItem(this.data);

  final HomePageHomepageTools data;

  @override
  Widget build(BuildContext context) {
    double width = (ScreenUtil.screenSize.width - $(48)) / 3;
    var title = data.category.title();
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular($(8)),
          child: VisibilityImageHolder(
            url: data.url,
            height: width * $(192.0) / $(110.0),
            width: width,
          ),
        ),
        TitleTextWidget(
          title.isEmpty ? data.categoryString! : title,
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
