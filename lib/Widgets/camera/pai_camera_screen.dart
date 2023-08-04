import 'package:camera/camera.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/camera/app_camera.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class PAICameraEntity {
  XFile xFile;
  String source;

  PAICameraEntity({required this.source, required this.xFile});
}

class PAICamera {
  static Future<PAICameraEntity?> takePhoto(BuildContext context) async {
    var bool = await PermissionsUtil.checkPermissions();
    if (!bool) {
      PermissionsUtil.permissionDenied(context);
      return null;
    }
    return Navigator.of(context).push<PAICameraEntity>(
      MaterialPageRoute(
        settings: RouteSettings(name: '/PAICameraScreen'),
        builder: (_) => PAICameraScreen(),
      ),
    );
  }
}

class PAICameraScreen extends StatefulWidget {
  const PAICameraScreen({Key? key}) : super(key: key);

  @override
  State<PAICameraScreen> createState() => _PAICameraScreenState();
}

class _PAICameraScreenState extends State<PAICameraScreen> {
  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'pai_camera_screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: AppCamera(onTakePhoto: (xFile, ration, source) {
        Navigator.of(context).pop(PAICameraEntity(source: source, xFile: xFile));
      }).intoContainer(
        width: ScreenUtil.screenSize.width,
        height: ScreenUtil.screenSize.height,
      ),
    );
  }
}
