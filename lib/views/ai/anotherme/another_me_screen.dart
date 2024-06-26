import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/camera/app_camera.dart';
import 'package:cartoonizer/widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/widgets/router/routers.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_controller.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_trans_screen.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class AnotherMeScreen extends StatefulWidget {
  RecentMetaverseEntity? entity;

  AnotherMeScreen({Key? key, this.entity}) : super(key: key);

  @override
  State<AnotherMeScreen> createState() => _AnotherMeScreenState();
}

class _AnotherMeScreenState extends State<AnotherMeScreen> {
  CacheManager cacheManager = AppDelegate().getManager();
  AnotherMeController controller = Get.put(AnotherMeController());

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'metaverse_camera_screen');
    if (widget.entity != null) {
      var file = File(widget.entity!.filePath.first);
      SyncFileImage(file: file).getImage().then((value) {
        var ratio = value.image.width / value.image.height;
        startTransfer(context, File(widget.entity!.originalPath!), ratio, file, 'recently');
      });
    }
  }

  @override
  void dispose() {
    Get.delete<AnotherMeController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: AppCamera(onTakePhoto: (xFile, ratio, width, height, source) async {
        startTransfer(context, await saveIfNotExist(xFile), ratio, null, source);
      }),
    );
  }

  Future<File> saveIfNotExist(XFile file) async {
    var path = await ImageUtils.onImagePick(file.path, cacheManager.storageOperator.recordMetaverseDir.path);
    return File(path);
  }

  startTransfer(BuildContext context, File file, double ratio, File? result, String photoType) {
    controller.clear();
    Navigator.of(context)
        .push<bool>(
      FadeRouter(
          settings: RouteSettings(name: '/AnotherMeTransScreen'),
          child: AnotherMeTransScreen(
            file: file,
            ratio: ratio,
            resultFile: result,
            photoType: photoType,
          )),
    )
        .then((value) {
      if (value != null) {
        if (value) {
          pop();
        }
      }
    });
  }
}
