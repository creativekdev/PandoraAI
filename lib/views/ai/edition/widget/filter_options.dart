import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/lib_image_widget/lib_image_widget.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/edition/controller/filter_holder.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
import 'package:flutter_image_filters/flutter_image_filters.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
                child: ScrollablePositionedList.separated(
              initialScrollIndex: 0,
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
        ).intoContainer(height: itemWidth + (24), width: ScreenUtil.screenSize.width),
        Text(
          controller.currentFunction.title(),
          style: TextStyle(
            color: Colors.white,
            fontSize: $(12),
            // fontWeight: controller.currentFunction == function ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ).intoContainer(alignment: Alignment.center),
      ],
    );
  }

  Widget buildItem(context, index, double itemWidth) {
    var function = controller.functions[index];
    var item = Container(
        width: itemWidth,
        height: itemWidth,
        padding: EdgeInsets.all(2),
        child: controller.thumbnails[function] == null
            ? SizedBox()
            : Image.memory(
                controller.thumbnails[function]!,
                fit: BoxFit.cover,
              ));
    return GestureDetector(
        onTap: () {
          controller.currentFunction = function;
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
            controller.currentFunction == function
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

class FilterPreviewCard extends StatefulWidget {
  File file;
  GroupShaderConfiguration configuration;
  double width;
  double height;

  FilterPreviewCard({
    super.key,
    required this.file,
    required this.configuration,
    required this.width,
    required this.height,
  });

  @override
  State<FilterPreviewCard> createState() => _FilterPreviewCardState();
}

class _FilterPreviewCardState extends State<FilterPreviewCard> {
  late TextureSource source;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    TextureSource.fromFile(widget.file).then((value) {
      source = value;
    }).whenComplete(() {
      safeSetState(() {
        loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loaded
        ? PipelineImageShaderPreview(
            configuration: widget.configuration,
            texture: source,
          ).intoCenter().intoContainer(width: widget.width, height: widget.height)
        : Container(
            width: widget.width,
            height: widget.height,
          );
  }
}
