import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/views/ai/edition/controller/filter_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/image_edition_controller.dart';

class FilterOptions extends StatelessWidget {
  AppState parentState;
  FilterHolder controller;

  FilterOptions({
    super.key,
    required this.controller,
    required this.parentState,
  });

  @override
  Widget build(BuildContext context) {
    var itemWidth = ScreenUtil.getCurrentWidgetSize(context).width / 6;
    return ScrollablePositionedList.separated(
      initialScrollIndex: 0,
      padding: EdgeInsets.symmetric(horizontal: $(12)),
      itemCount: controller.thumbnails.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        var function = controller.functions[index];
        var item = Container(
            width: itemWidth,
            height: itemWidth,
            padding: EdgeInsets.all(2.5),
            child: Image.memory(
              controller.thumbnails[function]!,
              fit: BoxFit.cover,
            ));
        return GestureDetector(
            onTap: () {
              controller.currentFunction = function;
              parentState.showLoading().whenComplete(() {
                controller.buildImage().then((value) {
                  parentState.hideLoading();
                });
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: $(1)),
                Text(function.name, style: TextStyle(color: Colors.white, fontSize: $(13))),
                SizedBox(height: $(5)),
                controller.currentFunction == function
                    ? OutlineWidget(
                        strokeWidth: 3,
                        radius: $(2),
                        gradient: LinearGradient(
                          colors: [Color(0xFF04F1F9), Color(0xFF7F97F3), Color(0xFFEC5DD8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        child: item)
                    : item,
              ],
            ));
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          width: $(1),
        );
      },
    );
  }
}
