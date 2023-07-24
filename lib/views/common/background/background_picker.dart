import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/background_card.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/color_util.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';

import 'background_picker_holder.dart';

class BackgroundPicker {
  static Future<BackgroundData?> pickBackground(
    BuildContext context, {
    required double imageRatio,
  }) async {
    var bool = await AnotherMe.checkPermissions();
    if (bool) {
      return _open(context, imageRatio: imageRatio);
    } else {
      AnotherMe.permissionDenied(context);
      return null;
    }
  }

  static Future<BackgroundData?> _open(
    BuildContext context, {
    required double imageRatio,
  }) async {
    return Navigator.of(context).push(
      NoAnimRouter(
        BackgroundPickerHolder(
          imageRatio: imageRatio,
        ),
        settings: RouteSettings(name: '/BackgroundPickerHolder'),
      ),
    );
  }
}

class BackgroundData {
  String? filePath;
  Color? color;

  BackgroundData();

  BackgroundData.fromJson(Map<String, dynamic> json) {
    if (json['filePath'] != null) {
      filePath = json['filePath'];
    }
    if (json['color'] != null) {
      color = ColorUtil.hexColor(json['color']);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    if (filePath != null) {
      result['filePath'] = filePath;
    }
    if (color != null) {
      result['color'] = ColorUtil.colorToHexString(color!);
    }
    return result;
  }
}

class BackgroundPickerBar extends StatefulWidget {
  double imageRatio;

  Function(BackgroundData data) onPick;

  BackgroundPickerBar({
    super.key,
    required this.imageRatio,
    required this.onPick,
  });

  @override
  State<BackgroundPickerBar> createState() => _BackgroundPickerBarState();
}

class _BackgroundPickerBarState extends State<BackgroundPickerBar> {
  double itemSize = 0;
  late double imageRatio;

  final List<Color> defaultColors = [Colors.white, Colors.black, Colors.transparent, Colors.yellow];
  CacheManager cacheManager = AppDelegate.instance.getManager();
  List<BackgroundData> dataList = [];

  @override
  void initState() {
    super.initState();
    imageRatio = widget.imageRatio;
    List<Map<String, dynamic>> jsonList = cacheManager.getJson(CacheManager.backgroundPickHistory) ?? [];
    dataList = jsonList.map((e) => BackgroundData.fromJson(e)).toList();
    if (dataList.length < 4) {
      dataList.addAll(defaultColors.sublist(0, 4 - dataList.length).map((e) => BackgroundData()..color = e).toList());
    }
    delay(() {
      setState(() {
        itemSize = (ScreenUtil.getCurrentWidgetSize(context).width - $(40)) / 5;
      });
    });
  }

  @override
  void didUpdateWidget(covariant BackgroundPickerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    imageRatio = widget.imageRatio;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> child = [
      Icon(
        Icons.add,
        size: $(28),
        color: ColorConstant.White,
      )
          .intoContainer(
              alignment: Alignment.center,
              width: itemSize,
              height: itemSize,
              margin: EdgeInsets.symmetric(horizontal: $(4)),
              decoration: BoxDecoration(color: Color(0x38ffffff), borderRadius: BorderRadius.circular(4)))
          .intoGestureDetector(onTap: () {
        BackgroundPicker.pickBackground(
          context,
          imageRatio: imageRatio,
        ).then((value) {
          if (value != null) {
            setState(() {
              dataList.insert(0, value);
              cacheManager.setJson(CacheManager.backgroundPickHistory, dataList.map((e) => e.toJson()).toList());
            });
            widget.onPick.call(value);
          }
        });
      }),
    ];
    child.addAll(dataList
        .sublist(0, 4)
        .map(
          (e) => ClipRRect(
            child: buildItem(e),
            borderRadius: BorderRadius.circular($(4)),
          ).intoGestureDetector(onTap: () {
            widget.onPick.call(e);
          }).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(4))),
        )
        .toList());
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: child,
    );
  }

  Widget buildItem(BackgroundData data) {
    if (data.filePath != null) {
      return Image(
        image: FileImage(File(data.filePath!)),
        width: itemSize,
        height: itemSize,
        fit: BoxFit.cover,
      );
    } else if (data.color != null) {
      return BackgroundCard(
          bgColor: data.color!,
          child: Container(
            width: itemSize,
            height: itemSize,
          ));
    } else {
      return Container(
        width: itemSize,
        height: itemSize,
      );
    }
  }
}
