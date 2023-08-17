import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/background_card.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/color_util.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:common_utils/common_utils.dart';

import '../../../images-res.dart';
import 'background_picker_holder.dart';

class BackgroundPicker {
  static Future pickBackground(
    BuildContext context, {
    required double imageRatio,
    required Function(BackgroundData data, bool isPopMerge) onPick,
    Function(BackgroundData data)? onColorChange,
    required BackgroundData preBackgroundData,
  }) async {
    var bool = await PermissionsUtil.checkPermissions();
    if (bool) {
      return _open(context, imageRatio: imageRatio, onPick: onPick, onColorChange: onColorChange, preBackgroundData: preBackgroundData);
    } else {
      PermissionsUtil.permissionDenied(context);
      return null;
    }
  }

  static Future _open(
    BuildContext context, {
    required double imageRatio,
    required Function(BackgroundData data, bool isPopMerge) onPick,
    Function(BackgroundData data)? onColorChange,
    required BackgroundData preBackgroundData,
  }) async {
    return Navigator.of(context).push(
      NoAnimRouter(
        BackgroundPickerHolder(
          imageRatio: imageRatio,
          onPick: onPick,
          onColorChange: onColorChange,
          preBackgroundData: preBackgroundData,
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
      result['color'] = color!.hexValue();
    }
    return result;
  }
}

class BackgroundPickerBar extends StatefulWidget {
  double imageRatio;

  Function(BackgroundData data, bool isPopMerge) onPick;
  Function(BackgroundData data) onColorChange;
  final BackgroundData preBackgroundData;
  Function() onSaved;
  Function() onClear;

  BackgroundPickerBar({
    super.key,
    required this.imageRatio,
    required this.onPick,
    required this.onColorChange,
    required this.preBackgroundData,
    required this.onSaved,
    required this.onClear,
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
    List<dynamic> jsonList = cacheManager.getJson(CacheManager.backgroundPickHistory) ?? [];
    dataList = jsonList.map((e) => BackgroundData.fromJson(e)).toList().filter((t) {
      if (TextUtil.isEmpty(t.filePath)) {
        return true;
      }
      return File(t.filePath!).existsSync();
    });
    if (!(cacheManager.getBool(CacheManager.isSavedPickHistory) ?? false)) {
      dataList.addAll(defaultColors.map((e) => BackgroundData()..color = e).toList());
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
    // imageRatio = widget.imageRatio;
    // List<dynamic> jsonList = cacheManager.getJson(CacheManager.backgroundPickHistory) ?? [];
    // dataList = jsonList.map((e) => BackgroundData.fromJson(e)).toList().filter((t) {
    //   if (TextUtil.isEmpty(t.filePath)) {
    //     return true;
    //   }
    //   return File(t.filePath!).existsSync();
    // });
    // dataList.addAll(defaultColors.map((e) => BackgroundData()..color = e).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all($(8)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Image.asset(Images.ic_bg_close, width: $(24)).intoGestureDetector(onTap: () {
              widget.onClear.call();
            }),
            Image.asset(
              Images.ic_bg_submit,
              width: $(24),
            ).intoGestureDetector(onTap: () {
              widget.onSaved.call();
            }),
          ]),
        ),
        Row(
          children: [
            UnconstrainedBox(
              child: Icon(
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
                  .intoGestureDetector(onTap: () async {
                var d;
                await BackgroundPicker.pickBackground(context, imageRatio: imageRatio, onPick: (data, isPopMerge) {
                  if (isPopMerge) {
                    d = data;
                    if (d != null) {
                      dataList.insert(0, d);
                    }
                    setState(() {
                      cacheManager.setBool(CacheManager.isSavedPickHistory, true);
                      cacheManager.setJson(CacheManager.backgroundPickHistory, dataList.map((e) => e.toJson()).toList());
                    });
                  } else {
                    widget.onPick.call(data, isPopMerge);
                  }
                }, onColorChange: (data) {
                  d = data;
                  widget.onColorChange.call(data);
                  setState(() {});
                }, preBackgroundData: widget.preBackgroundData);
              }),
            ),
            Container(
              height: itemSize,
              width: ScreenUtil.screenSize.width - itemSize - $(8) * 2,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: dataList
                      .map(
                        (e) => UnconstrainedBox(
                          child: ClipRRect(
                            child: buildItem(e),
                            borderRadius: BorderRadius.circular($(4)),
                          ).intoGestureDetector(onTap: () {
                            widget.onPick.call(e, false);
                          }).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(4))),
                        ),
                      )
                      .toList()),
            ),
          ],
        ),
      ],
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
