import 'dart:io';
import 'dart:developer';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'firebase_options.dart';
import 'package:flutter_applovin_max/flutter_applovin_max.dart';

import 'package:cartoonizer/common/dialog.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/common/utils.dart';
import 'package:cartoonizer/helper/shared_pref.dart';
import 'package:cartoonizer/views/HomeScreen.dart';
import 'package:cartoonizer/views/introduction/introduction_screen.dart';
import 'package:cartoonizer/api.dart';

import 'config.dart';

void main() async {
  // print the current configuration
  log("CONFIG: {apiHost: ${Config.instance.apiHost}, ANDROID_CHANNEL: ${ANDROID_CHANNEL}}");

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: ColorConstant.BackgroundColor,
  ));

  WidgetsFlutterBinding.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  // init get storage
  await GetStorage.init();

  // Show tracking authorization dialog and ask for permission
  await AppTrackingTransparency.requestTrackingAuthorization();

  // init firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // init firebase analytics
  await FirebaseAnalytics.instance.setDefaultEventParameters({"app_platform": Platform.operatingSystem, "app_version": packageInfo.version, "app_build": packageInfo.buildNumber});

  // init appsflyer
  Appsflyer.instance;

  // init applovin
  // FlutterApplovinMax.initSDK();
  FlutterApplovinMax.initInterstitialAd(AppLovinConfig.INTERSTITIAL_AD_ID);

  // run app
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    _checkIntroductionPage();

    // log app open
    logSystemEvent(Events.open_app);

    //2.页面初始化的时候，添加一个状态的监听者
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    //3. 页面销毁时，移出监听者
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _checkAppVersion() async {
    var data = await API.checkLatestVersion();
    if (data["need_update"] == true) {
      Get.dialog(
        CommonDialog(
          height: 385,
          barrierDismissible: false,
          dismissAfterConfirm: false,
          isCancel: false,
          content: Column(children: [
            Image(image: AssetImage(ImagesConstant.ic_update_image)),
            Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  children: [
                    Text(
                      StringConstant.new_update_dialog_title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        StringConstant.new_update_dialog_content,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black, height: 1.3),
                      ),
                    )
                  ],
                )),
          ]),
          confirmText: StringConstant.update_now,
          confirmCallback: () {
            var url = Config.getStoreLink();
            launchURL(url);
          },
        ),
      );
    }
  }

  _checkIntroductionPage() {
    SharedPreferencesHelper.getBool(SharedPreferencesHelper.keyHasIntroductionPageShowed).then((value) {
      if (value) {
        _checkAppVersion();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
          ModalRoute.withName('/HomeScreen'),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => IntroductionScreen()),
          ModalRoute.withName('/IntroductionScreen'),
        );
      }
    });
  }

  //监听程序进入前后台的状态改变的方法
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch (state) {
      //进入应用时候不会触发该状态 应用程序处于可见状态，并且可以响应用户的输入事件。它相当于 Android 中Activity的onResume
      case AppLifecycleState.resumed:
        print("didChangeAppLifecycleState-------> 应用进入前台======");
        break;
      //应用状态处于闲置状态，并且没有用户的输入事件，
      // 注意：这个状态切换到 前后台 会触发，所以流程应该是先冻结窗口，然后停止UI
      case AppLifecycleState.inactive:
        print("didChangeAppLifecycleState-------> 应用处于闲置状态，这种状态的应用应该假设他们可能在任何时候暂停 切换到后台会触发======");
        break;
      //当前页面即将退出
      case AppLifecycleState.detached:
        print("didChangeAppLifecycleState-------> 当前页面即将退出======");
        break;
      // 应用程序处于不可见状态
      case AppLifecycleState.paused:
        print("didChangeAppLifecycleState-------> 应用处于不可见状态 后台======");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: ColorConstant.BackgroundColor,
        ),
      ),
    );
  }
}
