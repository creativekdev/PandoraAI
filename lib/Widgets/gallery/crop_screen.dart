import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:crop_your_image/crop_your_image.dart';

class CropScreen extends StatefulWidget {
  static Future<XFile?> crop(
    BuildContext context, {
    required XFile image,
    Brightness brightness = Brightness.dark,
  }) async {
    return Navigator.of(context).push<XFile>(MaterialPageRoute(
      settings: RouteSettings(name: '/CropScreen'),
        builder: (_) => CropScreen(
              image: image,
              brightness: brightness,
            )));
  }

  XFile image;
  Brightness brightness;

  CropScreen({
    Key? key,
    required this.image,
    required this.brightness,
  }) : super(key: key);

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends AppState<CropScreen> {
  late XFile image;
  late Brightness brightness;
  Uint8List? imageList;
  Size? imageSize;

  CacheManager cacheManager = AppDelegate.instance.getManager();
  CropController cropController = CropController();

  @override
  void initState() {
    super.initState();
    image = widget.image;
    brightness = widget.brightness;
    delay(() {
      showLoading().whenComplete(() {
        SyncFileImage(file: File(image.path)).getImage().then((value) async {
          imageSize = Size(value.image.width.toDouble(), value.image.height.toDouble());
          var bytes = await value.image.toByteData(format: ImageByteFormat.png);
          hideLoading().whenComplete(() {
            setState(() {
              imageList = bytes!.buffer.asUint8List();
            });
          });
        });
      });
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: brightness == Brightness.dark ? ColorConstant.BackgroundColor : Colors.white,
      appBar: AppNavigationBar(
        backgroundColor: brightness == Brightness.dark ? ColorConstant.BackgroundColor : Colors.white,
        brightness: brightness,
        trailing: TitleTextWidget(S.of(context).ok, brightness == Brightness.dark ? ColorConstant.White : Colors.black, FontWeight.w500, $(16)).intoGestureDetector(onTap: () {
          showLoading().whenComplete(() {
            cropController.crop();
          });
        }),
      ),
      body: imageList == null
          ? Container()
          : Crop(
              image: imageList!,
              initialArea: Rect.fromLTWH(imageSize!.width / 4, imageSize!.height / 4, imageSize!.width / 2, imageSize!.width / 2),
              controller: cropController,
              onCropped: (bytes) {
                onCroped(bytes);
              }),
    );
  }

  onCroped(Uint8List bytes) {
    hideLoading().whenComplete(() async {
      String filePath = cacheManager.storageOperator.tempDir.path + 'crop-screen${DateTime.now().millisecondsSinceEpoch}.png';
      var file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      await file.writeAsBytes(bytes);
      hideLoading().whenComplete(() {
        Navigator.of(context).pop(XFile(filePath));
      });
    });
  }
}
