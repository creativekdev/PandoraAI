import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AnotherMe {
  static String logoBackTag = 'am_back_logo';
  static String takeItemTag = 'am_take_item';

  static Future<void> open(BuildContext context, {RecentMetaverseEntity? entity, required String source}) async {
    var result = await checkPermissions();
    if (result) {
      Events.metaverseLoading(source: source);
      return await Navigator.push<void>(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: "/AnotherMeScreen"),
          builder: (context) => AnotherMeScreen(
            entity: entity,
          ),
        ),
      );
    } else {
      permissionDenied(context);
    }
  }

  static Future<bool> checkPermissions() async {
    var list = [Permission.camera, Permission.storage, Permission.microphone];
    var deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfoPlugin.androidInfo;
      if (androidInfo.version.sdkInt > 31) {
        list.add(Permission.photos);
      }
    } else if (Platform.isIOS) {
      list.add(Permission.photos);
    }
    List<Permission> reqList = <Permission>[];
    for (var value in list) {
      var permissionStatus = await value.status;
      if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
        reqList.add(value);
      }
    }
    if (reqList.isEmpty) {
      return true;
    }
    var values = await reqList.request();
    for (var result in values.values) {
      if (result.isDenied || result.isPermanentlyDenied) {
        return false;
      }
    }
    return true;
  }

  static Future<void> permissionDenied(BuildContext context) async {
    var cameraStatus = await Permission.camera.status;
    if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
      showCameraPermissionDialog(context);
      return;
    }
    var microStatus = await Permission.microphone.status;
    if (microStatus.isDenied || microStatus.isPermanentlyDenied) {
      showMicroPhonePermissionDialog(context);
      return;
    }
    var galleryStatus = await Permission.photos.status;
    if (galleryStatus.isDenied || galleryStatus.isPermanentlyDenied) {
      showPhotoLibraryPermissionDialog(context);
      return;
    }
  }
}
