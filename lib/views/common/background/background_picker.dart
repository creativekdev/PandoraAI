import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/background_card.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/color_util.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:common_utils/common_utils.dart';

import '../../../Common/event_bus_helper.dart';
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
  bool? canDelete;

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

  BackgroundPickerBar({
    super.key,
    required this.imageRatio,
    required this.onPick,
    required this.onColorChange,
    required this.preBackgroundData,
  });

  @override
  State<BackgroundPickerBar> createState() => _BackgroundPickerBarState();
}

class _BackgroundPickerBarState extends State<BackgroundPickerBar> {
  double itemSize = 0;
  late double imageRatio;

  late StreamSubscription onHideDeleteEvent;

  final List<Color> defaultColors = [Colors.white, Colors.black, Colors.transparent, Colors.yellow];
  CacheManager cacheManager = AppDelegate.instance.getManager();
  List<BackgroundData> dataList = [];
  bool canReset = false;

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
      dataList.addAll(defaultColors
          .map((e) => BackgroundData()
            ..color = e
            ..canDelete = false)
          .toList());
    }
    onHideDeleteEvent = EventBusHelper().eventBus.on<OnHideDeleteStatusEvent>().listen((event) {
      setState(() {
        canReset = false;
      });
    });
    delay(() {
      setState(() {
        itemSize = (ScreenUtil.getCurrentWidgetSize(context).width - $(40)) / 5;
      });
    });
  }

  @override
  void dispose() {
    onHideDeleteEvent.cancel();
    super.dispose();
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
    return Row(
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
            setState(() {
              canReset = false;
            });
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
              children: dataList.transfer(
                (e, index) => UnconstrainedBox(
                  child: ClipRRect(
                    child: buildItem(e, index >= dataList.length - 4 ? false : canReset),
                    borderRadius: BorderRadius.circular($(4)),
                  ).intoGestureDetector(onTap: () {
                    setState(() {
                      canReset = false;
                    });
                    widget.onPick.call(e, false);
                  }).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(4))),
                ),
              )).intoGestureDetector(onLongPress: () {
            setState(() {
              canReset = true;
            });
          }),
        ),
      ],
    );
  }

  Widget buildItem(BackgroundData data, bool canDelete) {
    Widget child;
    if (data.filePath != null) {
      child = Image(
        image: FileImage(File(data.filePath!)),
        width: itemSize,
        height: itemSize,
        fit: BoxFit.cover,
      );
    } else if (data.color != null) {
      child = BackgroundCard(
          bgColor: data.color!,
          child: Container(
            width: itemSize,
            height: itemSize,
          ));
    } else {
      child = Container(
        width: itemSize,
        height: itemSize,
      );
    }
    return Stack(alignment: Alignment.topRight, children: [
      child,
      if (canDelete && data.canDelete != false)
        Icon(
          Icons.close_rounded,
          color: Colors.white,
          size: $(15),
        )
            .intoContainer(
          alignment: Alignment.center,
          width: $(20),
          height: $(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular($(4)),
          ),
        )
            .intoGestureDetector(onTap: () {
          setState(() {
            dataList.remove(data);
            cacheManager.setJson(CacheManager.backgroundPickHistory, dataList.map((e) => e.toJson()).toList());
          });
        })
    ]);
  }
}
