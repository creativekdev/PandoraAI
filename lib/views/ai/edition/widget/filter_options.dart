import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/background_card.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/views/ai/edition/controller/filters/filters_holder.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
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
    delay(() {
      if (controller.filterOperator.scrollController.isAttached) {
        var pos = (controller.filterOperator.filters.findPosition((data) => data == controller.filterOperator.currentFilter) ?? 0);
        if (pos == 0) {
          return;
        }
        controller.filterOperator.scrollController.scrollTo(index: pos - 1, duration: Duration(milliseconds: 300));
      }
    });
    return Column(
      children: [
        Row(
          children: [
            Container(width: $(12)),
            buildItem(context, 0, itemWidth),
            Container(width: $(1)),
            Expanded(
                child: ScrollablePositionedList.separated(
              initialScrollIndex: 0,
              itemScrollController: controller.filterOperator.scrollController,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.only(right: $(12)),
              itemCount: controller.thumbnails.length - 1,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return buildItem(context, index + 1, itemWidth);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container(width: $(0));
              },
            )),
          ],
        ).intoContainer(height: itemWidth + (12), width: ScreenUtil.screenSize.width),
        Text(
          controller.filterOperator.currentFilter.title(),
          style: TextStyle(
            color: Colors.white,
            fontSize: $(13),
            fontWeight: FontWeight.bold,
            // fontWeight: controller.currentFunction == function ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ).intoContainer(alignment: Alignment.center),
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
          EventBusHelper().eventBus.fire(OnEditionRightTabSwitchEvent(data: function.title()));
          parentState.showLoading().whenComplete(() {
            controller.buildImage().then((value) {
              parentState.hideLoading();
            });
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
