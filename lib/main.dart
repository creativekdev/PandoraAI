import 'dart:developer';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cartoonizer/Common/dialog.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/kochava.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/home_screen.dart';
import 'package:cartoonizer/views/introduction/introduction_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app/app.dart';
import 'config.dart';
import 'firebase_options.dart';

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
    name: 'cartoonizer',
  );
  if (kReleaseMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
  }

  // init firebase analytics
  await FirebaseAnalytics.instance.setDefaultEventParameters({"app_platform": Platform.operatingSystem, "app_version": packageInfo.version, "app_build": packageInfo.buildNumber});

  // init appsflyer
  // Appsflyer.instance;
  KoChaVa.instance.init();

  // init admob
  MobileAds.instance.initialize();
  // run app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppDelegate.instance.init();
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          theme: ThemeData(platform: Platform.isIOS ? TargetPlatform.iOS : TargetPlatform.android),
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
  late StreamSubscription onSplashAdLoadingListener;

  @override
  void initState() {
    super.initState();
    onSplashAdLoadingListener = EventBusHelper().eventBus.on<OnSplashAdLoadingChangeEvent>().listen((event) {
      if (!AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.isLoadingAd) {
        openApp();
      }
    });

    waitAppInitialize();

    //2.页面初始化的时候，添加一个状态的监听者
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    //3. 页面销毁时，移出监听者
    WidgetsBinding.instance.removeObserver(this);
    onSplashAdLoadingListener.cancel();
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
          content: ClipRRect(
            borderRadius: BorderRadius.circular($(8)),
            child: Column(children: [
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
          ),
          confirmText: StringConstant.update_now,
          confirmCallback: () {
            var url = Config.getStoreLink();
            launchURL(url);
          },
        ),
      );
    }
  }

  waitAppInitialize() {
    if (AppDelegate.instance.initialized) {
      _checkIntroductionPage();
    } else {
      Function(bool status)? listener;
      listener = (status) {
        if (status) {
          _checkIntroductionPage();
          AppDelegate.instance.cancelListenAsync(listener!);
        }
      };
      AppDelegate.instance.listen(listener);
    }
  }

  _checkIntroductionPage() {
    // log app open
    logSystemEvent(Events.open_app);
    var value = AppDelegate.instance.getManager<CacheManager>().getBool(CacheManager.keyHasIntroductionPageShowed);
    if (value) {
      _checkAppVersion();
      var thirdpartManager = AppDelegate.instance.getManager<ThirdpartManager>();
      thirdpartManager.adsHolder.initHolder();
      delay(() => openApp(force: true), milliseconds: 2000);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => IntroductionScreen()),
        ModalRoute.withName('/IntroductionScreen'),
      );
    }
  }

  void openApp({bool force = false}) {
    var forward = () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomeScreen(),
          settings: RouteSettings(name: "/HomeScreen"),
        ),
        ModalRoute.withName('/HomeScreen'),
      );
    };
    if (force) {
      forward.call();
    } else {
      AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.showIfAvailable(callback: () {
        forward.call();
      });
    }
  }

  //监听程序进入前后台的状态改变的方法
  /// dead code。
  /// 此方法不生效，因为push到homescreen的时候当前页面就被销毁了。所以之前的adContainer报错也是一直没有得到fix。
  /// 新实现在ThirdpartManager里，使用了google ads的AppStateEventNotifier
  /// 如果要使用此段代码，可以搬到home screen中，但是home screen在使用过程中还是会被重启，所以放在了ThirdpartManager中。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
      backgroundColor: Colors.black,
      body: Platform.isIOS
          ? Image.asset(
              Images.ic_launcher_bg,
              height: double.maxFinite,
            ).intoCenter()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  Images.launch_branding,
                  width: ScreenUtil.screenSize.width * 0.42,
                ).visibility(
                  visible: false,
                  maintainState: true,
                ),
                Expanded(
                    child: Image.asset(
                  Images.launch_icon,
                  width: ScreenUtil.screenSize.width * 0.4,
                )),
                Image.asset(
                  Images.launch_branding,
                  width: ScreenUtil.screenSize.width * 0.42,
                ),
              ],
            ).intoContainer(width: double.maxFinite, height: double.maxFinite),
    );
  }
}
