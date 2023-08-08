import 'dart:io';

import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/views/ai/edition/controller/remove_bg_holder.dart';
import 'package:cartoonizer/views/common/background/background_picker.dart';
import 'package:cartoonizer/views/mine/filter/im_pin_view.dart';
import 'package:image/image.dart' as imgLib;

class RemoveBgOptions extends StatelessWidget {
  RemoveBgHolder controller;

  RemoveBgOptions({super.key, required this.controller, required this.bottomPadding, required this.switchButtonPadding});

  final double bottomPadding;
  final double switchButtonPadding;

  @override
  Widget build(BuildContext context) {
    return BackgroundPickerBar(
      imageRatio: controller.ratio,
      onPick: (BackgroundData data) async {
        if (data.filePath != null) {
          File backFile = File(data.filePath!);
          controller.backgroundColor = null;
          controller.backgroundImage = backFile;
        } else {
          controller.backgroundImage = null;
          controller.backgroundColor = controller.rgbaToAbgr(data.color!);
        }
        controller.update();
        showPersonEditScreenDialog(context, bottomPadding, switchButtonPadding);
      },
    ).intoContainer(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: $(4)),
    );
  }

  void showPersonEditScreenDialog(BuildContext context, double bottomPadding, double switchButtonPadding) {
    Navigator.push(
      context,
      NoAnimRouter(
        settings: RouteSettings(name: "/ImEffectScreen"),
        ImPinView(
          personImage: controller.imageFront!,
          personImageForUI: controller.imageUiFront!,
          backgroundImage: controller.imageBack,
          backgroundColor: controller.backgroundColor,
          originFile: controller.originFile!,
          bottomPadding: bottomPadding,
          switchButtonPadding: switchButtonPadding,
          onAddImage: (image) {
            Uint8List byte = Uint8List.fromList(imgLib.encodeJpg(image));
            CacheManager cacheManager = AppDelegate.instance.getManager();
            var path = cacheManager.storageOperator.removeBgDir.path + '${DateTime.now().millisecondsSinceEpoch}.jpg';
            File(path).writeAsBytes(byte).then((value) {
              controller.resultFilePath = path;
            });
          },
        ),
      ),
    );
  }
}
