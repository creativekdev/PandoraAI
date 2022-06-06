import 'dart:developer';
import 'firebase_options.dart';

import 'package:cartoonizer/Common/dialog.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/utils.dart';
import 'package:cartoonizer/Ui/home/HomeScreen.dart';
import 'package:cartoonizer/api.dart';

import 'config.dart';

void main() async {
  log("CONFIG: {apiHost: ${Config.instance.apiHost}, ANDROID_CHANNEL: ${ANDROID_CHANNEL}}");

  // init get storage
  await GetStorage.init();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
  ));

  WidgetsFlutterBinding.ensureInitialized();

  // init firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          title: 'Cartoonizer',
          home: MyHomePage(title: 'Cartoonizer'),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _checkAppVersion();
  }

  Future<void> _checkAppVersion() async {
    var data = await API.checkLatestVersion();
    if (data["need_update"] == true) {
      Get.dialog(
        CommonDialog(
          barrierDismissible: false,
          dismissAfterConfirm: false,
          image: ImagesConstant.ic_success,
          content: StringConstant.new_version_available,
          isCancel: false,
          confirmContent: StringConstant.update_now,
          confirmCallback: () {
            var url = Config.getStoreLink();
            launchURL(url);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: HomeScreen(),
      ),
    );
  }
}
