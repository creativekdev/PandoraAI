import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/widgets/visibility_holder.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';

import '../../common/importFile.dart';
import '../../models/home_page_entity.dart';

typedef OnClickItem = Function(HomePageHomepageTools data);

class PaiRecommendView extends StatelessWidget {
  late List<HomePageHomepageTools> list;
  final OnClickItem onClickItem;
  final HomeItemEntity data;

  PaiRecommendView({Key? key, required this.data, required this.onClickItem, required Map<String, dynamic> locale}) : super(key: key) {
    list = data.getDataList<HomePageHomepageTools>();
    for (var element in list) {
      element.title = element.categoryString?.localeValue(locale) ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final finalList = list.where((t) => t.category != HomeCardType.nothing && t.category != HomeCardType.UNDEFINED).toList();
    return Container(
      padding: EdgeInsets.only(left: 15.dp, right: 15.dp, top: 12.dp),
      child: Wrap(
        spacing: 14.dp,
        runSpacing: 14.dp,
        children: finalList
            .map(
              (e) => RecommendItem(e, data.hasBackground).intoGestureDetector(
                onTap: () {
                  onClickItem(e);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class RecommendItem extends StatelessWidget {
  RecommendItem(this.data, this.hasBackground);

  final bool hasBackground;
  final HomePageHomepageTools data;

  @override
  Widget build(BuildContext context) {
    double width = (ScreenUtil.screenSize.width - 46.dp) / 2;
    var title = data.category.title();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular($(8)),
          child: VisibilityImageHolder(
            url: data.url,
            width: width - 16.dp,
            height: (width - 16.dp) / (158.dp / 200.dp),
          ),
        ).intoContainer(
          padding: EdgeInsets.all(8.dp),
        ),
        TitleTextWidget(
          title.isEmpty ? data.categoryString! : title,
          Colors.white,
          FontWeight.w400,
          12.sp,
          maxLines: 1,
        ).intoContainer(
          width: width,
          padding: EdgeInsets.only(bottom: 8.dp),
        )
      ],
    ).intoContainer(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.dp),
          gradient: LinearGradient(
            colors: hasBackground
                ? [
                    Color(0x881EF0F6),
                    Color(0x8865ABF1),
                    Color(0x888095F2),
                    Color(0x88978BEA),
                    Color(0x88AE7EE6),
                    Color(0x88D16BDD),
                    Color(0x88DF62D8),
                  ]
                : [
                    Color(0xff181818),
                    Color(0xff181818),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
    );
  }
}
