import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/views/ai/edition/controller/filters/filters_holder.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
import 'package:cartoonizer/widgets/background_card.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:skeletons/skeletons.dart';

class FilterOptions extends StatelessWidget {
  AppState parentState;
  FiltersHolder controller;

  FilterOptions({
    super.key,
    required this.controller,
    required this.parentState,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.thumbnails.isEmpty) {
      return Container();
    }
    var itemWidth = ScreenUtil.getCurrentWidgetSize(context).width / 6.2;
    return Column(
      children: [
        Row(
          children: [
            Container(width: $(12)),
            buildItem(context, 0, itemWidth),
            Container(width: $(1)),
            Expanded(
              child: ListView.builder(
                controller: controller.filterOperator.scrollController,
                itemBuilder: (context, index) => buildItem(context, index + 1, itemWidth),
                scrollDirection: Axis.horizontal,
                itemCount: controller.thumbnails.length - 1,
                padding: EdgeInsets.only(right: $(12)),
              ),
            ),
          ],
        ).intoContainer(height: itemWidth + (24), width: ScreenUtil.screenSize.width),
      ],
    );
  }

  Widget buildItem(context, index, double itemWidth) {
    var function = controller.filterOperator.filters[index];
    var item = Container(
        width: itemWidth,
        height: itemWidth,
        padding: EdgeInsets.all(2),
        child: controller.thumbnails[function] == null
            ? SkeletonAvatar(
                style: SkeletonAvatarStyle(
                width: itemWidth,
                height: itemWidth,
              ))
            : BackgroundCard(
                bgColor: Colors.transparent,
                w: 4,
                h: 4,
                child: Image.memory(
                  controller.thumbnails[function]!,
                  fit: BoxFit.cover,
                ),
              ));
    return GestureDetector(
        onTap: () {
          controller.filterOperator.currentFilter = function;
          parentState.showLoading().whenComplete(() {
            controller.buildCropImage();
            controller.buildImage().then((value) {
              parentState.hideLoading();
            });
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TitleTextWidget(function.title(), controller.filterOperator.currentFilter == function ? Colors.white : ColorConstant.EffectGrey, FontWeight.normal, 9.sp),
            SizedBox(height: $(2)),
            controller.filterOperator.currentFilter == function
                ? item.intoContainer(
                    // padding: EdgeInsets.all($(1)),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: $(2)),
                      borderRadius: BorderRadius.circular($(4)),
                    ),
                  )
                : item.intoContainer(padding: EdgeInsets.symmetric(vertical: $(2), horizontal: $(2))),
          ],
        ));
  }
}
