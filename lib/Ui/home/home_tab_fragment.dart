import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Controller/home_data_controller.dart';
import 'package:cartoonizer/Ui/ChoosePhotoScreen.dart';

import '../../Common/importFile.dart';
import '../../Model/EffectModel.dart';
import 'HomeScreen.dart';

class HomeTabFragment extends StatefulWidget {
  HomeDataController controller;

  HomeTabFragment({Key? key, required this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeTabFragmentState();
  }
}

class HomeTabFragmentState extends State<HomeTabFragment>
    with AutomaticKeepAliveClientMixin {
  late HomeDataController controller;
  List<EffectModel> dataList = [];

  @override
  initState() {
    super.initState();
    controller = widget.controller;
  }

  changeData(List<EffectModel> dataList) {
    setState(() {
      this.dataList = dataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<HomeDataController>(
        init: controller,
        builder: (_) {
          var dataList = _.dataList ?? [];
          return Scaffold(
              body: ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: "/ChoosePhotoScreen"),
                    builder: (context) =>
                        ChoosePhotoScreen(list: dataList, pos: index),
                  ),
                )
              },
              child: Container(
                margin: EdgeInsets.only(left: 5.w, right: 5.w, bottom: 2.h),
                child: Card(
                  elevation: 1.h,
                  shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 1.5.w),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(2.w)),
                                          child: dataList[index]
                                                      .key
                                                      .toString() ==
                                                  "transform"
                                              ? CachedNetworkImage(
                                                  imageUrl:
                                                      "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" +
                                                          dataList[index].key +
                                                          ".webp",
                                                  fit: BoxFit.fill,
                                                  height: 41.w,
                                                  width: 41.w,
                                                  placeholder:
                                                      cachedNetworkImagePlaceholder,
                                                  errorWidget:
                                                      cachedNetworkImageErrorWidget,
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl:
                                                      "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" +
                                                          dataList[index].key +
                                                          ".mobile.jpg",
                                                  fit: BoxFit.fill,
                                                  height: 41.w,
                                                  width: 41.w,
                                                  placeholder:
                                                      cachedNetworkImagePlaceholder,
                                                  errorWidget:
                                                      cachedNetworkImageErrorWidget,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 0.w),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(2.w)),
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          child: dataList[index]
                                                      .key
                                                      .toString() ==
                                                  "transform"
                                              ? CachedNetworkImage(
                                                  imageUrl:
                                                      "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" +
                                                          dataList[index].key +
                                                          "1.webp",
                                                  fit: BoxFit.fill,
                                                  height: 41.w,
                                                  width: 41.w,
                                                  placeholder:
                                                      cachedNetworkImagePlaceholder,
                                                  errorWidget:
                                                      cachedNetworkImageErrorWidget,
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl:
                                                      "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" +
                                                          dataList[index].key +
                                                          "1.jpg",
                                                  fit: BoxFit.fill,
                                                  height: 41.w,
                                                  width: 41.w,
                                                  placeholder:
                                                      cachedNetworkImagePlaceholder,
                                                  errorWidget:
                                                      cachedNetworkImageErrorWidget,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (dataList[index].key.toString() != "transform")
                              SizedBox(
                                height: 1.5.w,
                              ),
                            if (dataList[index].key.toString() != "transform")
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 1.5.w),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(2.w)),
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                            child: dataList[index]
                                                        .key
                                                        .toString() ==
                                                    "transform"
                                                ? CachedNetworkImage(
                                                    imageUrl:
                                                        "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" +
                                                            dataList[index]
                                                                .key +
                                                            "2.webp",
                                                    fit: BoxFit.fill,
                                                    height: 41.w,
                                                    width: 41.w,
                                                    placeholder:
                                                        cachedNetworkImagePlaceholder,
                                                    errorWidget:
                                                        cachedNetworkImageErrorWidget,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl:
                                                        "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" +
                                                            dataList[index]
                                                                .key +
                                                            "2.jpg",
                                                    fit: BoxFit.fill,
                                                    height: 41.w,
                                                    width: 41.w,
                                                    placeholder:
                                                        cachedNetworkImagePlaceholder,
                                                    errorWidget:
                                                        cachedNetworkImageErrorWidget,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (dataList[index].effects.length >= 3)
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 0.w),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(2.w)),
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              child: dataList[index]
                                                          .key
                                                          .toString() ==
                                                      "transform"
                                                  ? CachedNetworkImage(
                                                      imageUrl:
                                                          "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" +
                                                              dataList[index]
                                                                  .key +
                                                              "3.webp",
                                                      fit: BoxFit.fill,
                                                      height: 41.w,
                                                      width: 41.w,
                                                      placeholder:
                                                          cachedNetworkImagePlaceholder,
                                                      errorWidget:
                                                          cachedNetworkImageErrorWidget,
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl:
                                                          "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" +
                                                              dataList[index]
                                                                  .key +
                                                              "3.jpg",
                                                      fit: BoxFit.fill,
                                                      height: 41.w,
                                                      width: 41.w,
                                                      placeholder:
                                                          cachedNetworkImagePlaceholder,
                                                      errorWidget:
                                                          cachedNetworkImageErrorWidget,
                                                    ),
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
                        padding:
                            EdgeInsets.only(left: 3.w, right: 3.w, bottom: 3.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TitleTextWidget(
                                  (dataList[index].display_name.toString() ==
                                          "null")
                                      ? dataList[index].key
                                      : dataList[index].display_name,
                                  ColorConstant.BtnTextColor,
                                  FontWeight.w600,
                                  14.sp,
                                  align: TextAlign.start),
                            ),
                            Image.asset(
                              ImagesConstant.ic_next,
                              height: 14.w,
                              width: 14.w,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ));
        });
  }

  @override
  bool get wantKeepAlive => true;
}
