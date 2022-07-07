import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/views/ChoosePhotoScreen.dart';

import 'widget/effect_full_body_card_widget.dart';

class EffectRecentFragment extends StatefulWidget {
  RecentController controller;

  EffectRecentFragment({Key? key, required this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EffectRecentFragmentState();
}

class EffectRecentFragmentState extends State<EffectRecentFragment> with AutomaticKeepAliveClientMixin {
  late RecentController recentController;

  @override
  initState() {
    super.initState();
    recentController = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var width = ScreenUtil.getCurrentWidgetSize(context).width - $(40);
    return GetBuilder<RecentController>(
        init: recentController,
        builder: (_) {
          return _.dataList.isEmpty
              ? Text(
                  'No record of your usage found\n'
                  'Please make your first profile pic to view your history here',
                  style: TextStyle(
                    color: ColorConstant.White,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    fontSize: $(17),
                  ),
                  textAlign: TextAlign.center,
                ).intoContainer(alignment: Alignment.center, margin: EdgeInsets.all($(25))).intoCenter()
              : MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: _.dataList.length,
                    itemBuilder: (context, index) => EffectFullBodyCardWidget(
                      parentWidth: width,
                      data: _.dataList[index],
                      onTap: (data) {
                        _onEffectCategoryTap(_.recentModelList, _.dataList, data);
                      },
                    ).intoContainer(
                      margin: EdgeInsets.only(
                        left: $(20),
                        right: $(20),
                        top: index == 0 ? $(132) : $(8),
                        bottom: index == _.dataList.length - 1 ? ($(8) + AppTabBarHeight) : $(8),
                      ),
                    ),
                  ),
                );
        });
  }

  _onEffectCategoryTap(List<EffectModel> originList, List<List<EffectItemListData>> dataList, EffectItemListData data) {
    EffectModel? effectModel;
    int index = 0;
    for (int i = 0; i < originList.length; i++) {
      var model = originList[i];
      var list = model.effects.values.toList();
      bool find = false;
      for (int j = 0; j < list.length; j++) {
        var item = list[j];
        if ('${model.key}${item.key}' == data.uniqueKey) {
          effectModel = model;
          index = i;
          find = true;
          break;
        }
      }
      if (find) {
        break;
      }
    }
    if (effectModel == null) {
      return;
    }
    logEvent(Events.choose_home_cartoon_type, eventValues: {
      "category": effectModel.key,
      "style": effectModel.style,
      "page": "recent",
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ChoosePhotoScreen"),
        builder: (context) => ChoosePhotoScreen(
          list: originList,
          pos: index,
          itemPos: 0,
          isFromRecent: true,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
