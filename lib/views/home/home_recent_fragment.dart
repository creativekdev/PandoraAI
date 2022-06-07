import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/models/EffectModel.dart';

import '../ChoosePhotoScreen.dart';
import 'HomeScreen.dart';

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
          return _.recentList.isEmpty
              ? Text(
                  'you haven\'t used any picture yet, try to use now',
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
                  itemCount: _.recentList.length,
                  itemBuilder: (context, index) =>
                      _buildEffectCategoryCard(context, _.recentList, index)
                          .intoContainer(
                    margin: EdgeInsets.only(
                        left: $(20),
                        right: $(20),
                        top: index == 0 ? $(16) : $(8),
                        bottom: $(8)),
                  )
                          .intoGestureDetector(onTap: () {
                    _onEffectCategoryTap(
                        _.recentList.map((e) => e.effectModel).toList(), index);
                  }),
                );
        });
  }

  Widget _imageWidget(BuildContext context, {required String url}) =>
      CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.fill,
        height: $(150),
        width: $(150),
        placeholder: cachedNetworkImagePlaceholder,
        errorWidget: cachedNetworkImageErrorWidget,
      );

  Widget _buildEffectCategoryCard(
      BuildContext context, List<RecentEffectModel> list, int index) {
    var data = list[index].effectModel;
    return Card(
      color: ColorConstant.CardColor,
      elevation: 1.h,
      shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all($(6)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all($(6)),
                        child: ClipRRect(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.w)),
                            child:
                                _imageWidget(context, url: data.getShownUrl())),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all($(6)),
                        child: Stack(
                          children: [
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.w)),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: _imageWidget(context,
                                    url: data.getShownUrl(pos: 1))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (data.key != "transform")
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all($(6)),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.w)),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: _imageWidget(context,
                                    url: data.getShownUrl(pos: 2)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (data.effects.length >= 3)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all($(6)),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2.w)),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: _imageWidget(context,
                                      url: data.getShownUrl(pos: 3)),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 3.w, right: 3.w, bottom: 3.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TitleTextWidget(
                      (data.display_name.toString() == "null")
                          ? data.key
                          : data.display_name,
                      ColorConstant.BtnTextColor,
                      FontWeight.w600,
                      17,
                      align: TextAlign.start),
                ),
                Image.asset(
                  ImagesConstant.ic_next,
                  height: $(50),
                  width: $(50),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    recentController.onEffectUsed(list[index]);
  }

  @override
  bool get wantKeepAlive => true;
}
