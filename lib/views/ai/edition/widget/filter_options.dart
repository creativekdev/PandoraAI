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
    var itemWidth = ScreenUtil.getCurrentWidgetSize(context).width / 6;
    return Column(
      children: [
        Row(
          children: [
            Container(width: $(15)),
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
                return Container(width: $(1));
              },
            )),
          ],
        ).intoContainer(height: itemWidth + (24), width: ScreenUtil.screenSize.width),
      ],
    );
  }

  Widget buildItem(context, index, double itemWidth) {
    var function = controller.functions[index];
    var item = Container(
        width: itemWidth,
        height: itemWidth,
        padding: EdgeInsets.all(2.5),
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
            Text(
              function.title(),
              style: TextStyle(
                color: Colors.white,
                fontSize: $(10),
                fontWeight: controller.currentFunction == function ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            SizedBox(height: $(2)),
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
  }
}

class FilterPreviewCard extends StatefulWidget {
  Uint8List bytes;
  ShaderConfiguration configuration;
  double width;
  double height;

  FilterPreviewCard({
    super.key,
    required this.bytes,
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
    TextureSource.fromMemory(widget.bytes).then((value) {
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
        ? ImageShaderPreview(
            configuration: widget.configuration,
            texture: source,
          ).intoContainer(width: widget.width, height: widget.height)
        : Container(
            width: widget.width,
            height: widget.height,
          );
  }
}
