import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/views/ChoosePhotoScreen.dart';
import 'package:cartoonizer/views/home/home_effect_card_widget.dart';

class HomeRecentFragment extends StatefulWidget {
  RecentController controller;

  HomeRecentFragment({Key? key, required this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeRecentFragmentState();
}

class HomeRecentFragmentState extends State<HomeRecentFragment>
    with AutomaticKeepAliveClientMixin {
  late RecentController recentController;

  @override
  initState() {
    super.initState();
    recentController = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                )
                  .intoContainer(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all($(25)))
                  .intoCenter()
              : ListView.builder(
                  itemCount: _.dataList.length,
                  itemBuilder: (context, index) => HomeEffectCardWidget(
                    data: _.dataList[index],
                  )
                      .intoContainer(
                    margin: EdgeInsets.only(
                        left: $(20),
                        right: $(20),
                        top: index == 0 ? $(16) : $(8),
                        bottom: $(8)),
                  )
                      .intoGestureDetector(onTap: () {
                    _onEffectCategoryTap(_.dataList, index);
                  }),
                );
        });
  }

  _onEffectCategoryTap(List<EffectModel> list, int index) async {
    logEvent(Events.choose_home_cartoon_type,
        eventValues: {"category": list[index].key, "style": list[index].style});

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ChoosePhotoScreen"),
        builder: (context) => ChoosePhotoScreen(list: list, pos: index),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
