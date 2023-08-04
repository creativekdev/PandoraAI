import 'dart:developer';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cartoonizer/Common/dialog.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/kochava.dart';
import 'package:cartoonizer/Common/navigator_observer.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/common/apk_download_screen.dart';
import 'package:cartoonizer/views/home_screen.dart';
import 'package:cartoonizer/views/introduction/introduction_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

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
      if (details.library == 'image resource service') {
        LogUtil.e(details.toString());
      } else {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      }
    };
  }

  // init firebase analytics
  FirebaseAnalytics.instance.setDefaultEventParameters({"app_platform": Platform.operatingSystem, "app_version": packageInfo.version, "app_build": packageInfo.buildNumber});

  // init appsflyer
  // Appsflyer.instance;
  KoChaVa.instance.init();
  // init admob
  MobileAds.instance.initialize();
  // await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ['F6236D69A8A84479F17A3C6D0EAB1C53']));
  // run app
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  int lastLocaleTime = 0;
  static String currentLocales = 'en';

  static AppRouteObserver routeObserver = AppRouteObserver();

  @override
  Widget build(BuildContext context) {
    AppDelegate.instance.init();
    return GetMaterialApp(
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        platform: Platform.isIOS ? TargetPlatform.iOS : TargetPlatform.android,
        scaffoldBackgroundColor: ColorConstant.BackgroundColor,
        fontFamily: 'Poppins',
      ),
      title: APP_TITLE,
      home: MyHomePage(title: APP_TITLE),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) => onLocaleChanged(deviceLocale, supportedLocales),
      locale: const Locale('en', 'US'),
      supportedLocales: S.delegate.supportedLocales,
    ).skeletonTheme();
  }

  Locale? onLocaleChanged(Locale? deviceLocale, Iterable<Locale> supportedLocales) {
    var current = DateTime.now().millisecondsSinceEpoch;
    var duration = current - lastLocaleTime;
    Locale? result;
    if (duration > 2000) {
      lastLocaleTime = current;
      debugPrint('deviceLocale: ${deviceLocale!.languageCode}');
      currentLocales = deviceLocale.languageCode;
      result = deviceLocale;
    } else {
      for (var locale in supportedLocales) {
        if (locale.languageCode == currentLocales) {
          result = locale;
          break;
        }
      }
    }
    if (AppDelegate.instance.initialized) {
      ThirdpartManager thirdpartManager = AppDelegate().getManager();
      thirdpartManager.initRefresh(result);
    } else {
      Function(bool status)? listener;
      listener = (status) {
        if (status) {
          ThirdpartManager thirdpartManager = AppDelegate().getManager();
          thirdpartManager.initRefresh(result);
          AppDelegate.instance.cancelListenAsync(listener!);
        }
      };
      AppDelegate.instance.listen(listener);
    }
    return result ?? deviceLocale;
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription onSplashAdLoadingListener;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    onSplashAdLoadingListener = EventBusHelper().eventBus.on<OnSplashAdLoadingChangeEvent>().listen((event) {
      if (!AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.isLoadingAd) {
        openApp();
      }
    });

    waitAppInitialize();
  }

  @override
  void dispose() {
    super.dispose();
    onSplashAdLoadingListener.cancel();
  }

  Future<bool?> _checkAppVersion() async {
    var data = await AppApi.quickResponse().checkAppVersion();
    if (data["need_update"] == true) {
      return await Get.dialog<bool>(
        CommonDialog(
          height: 385,
          barrierDismissible: !data['force'],
          dismissAfterConfirm: !data['force'],
          isCancel: !data['force'],
          content: ClipRRect(
            borderRadius: BorderRadius.circular($(8)),
            child: Column(children: [
              Image(image: AssetImage(ImagesConstant.ic_update_image)),
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    children: [
                      Text(
                        S.of(context).new_update_dialog_title,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                          data['force'] ? S.of(context).new_update_dialog_content : S.of(context).new_update_dialog_content_cancellable,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black, height: 1.3),
                        ),
                      )
                    ],
                  )),
            ]),
          ),
          confirmText: S.of(context).update_now,
          confirmCallback: () async {
            if (Platform.isAndroid) {
              if (!TextUtil.isEmpty(data['url']?.toString() ?? '') && MyApp.currentLocales == 'zh') {
                var downloadsDirectory = await getExternalStorageDirectory();
                var filePath = downloadsDirectory!.path + '/Download/${APP_NAME}_${data['latest_build']}.apk';
                if (File(filePath).existsSync()) {
                  installApk(fileName: filePath);
                } else {
                  ApkDownloadScreen.start(
                    context,
                    url: data['url'],
                    filePath: filePath,
                    force: data['force'],
                  ).then((value) {
                    if (value ?? false) {
                      installApk(fileName: filePath);
                    } else {
                      if (!data['force']) {
                        Navigator.of(context).pop();
                      }
                    }
                  });
                  // CommonExtension().showToast('Start downloading, wait a moment please');
                  // updateByApk(url: data['url'], name: "${APP_NAME}_${data['latest_build']}.apk");
                }
              } else {
                const platform = MethodChannel(PLATFORM_CHANNEL);
                platform.invokeMethod<bool>("openAppStore").then((value) {
                  if (value == false) {
                    var url = Config.getStoreLink();
                    launchURL(url);
                  }
                });
              }
            } else {
              var url = Config.getStoreLink();
              launchURL(url);
            }
          },
        ),
      );
    } else {
      return true;
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
    Get.put(UploadImageController());
    Posthog().screenWithUser(screenName: 'entry_screen');
    var value = AppDelegate.instance.getManager<CacheManager>().getBool(CacheManager.keyHasIntroductionPageShowed);
    if (value) {
      _checkAppVersion().then((value) {
        var thirdpartManager = AppDelegate.instance.getManager<ThirdpartManager>();
        thirdpartManager.adsHolder.initHolder();
        delay(() => openApp(force: true), milliseconds: 2000);
      });
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(settings: RouteSettings(name: '/IntroductionScreen'), builder: (BuildContext context) => IntroductionScreen()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
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
                  maintainSize: true,
                  maintainAnimation: true,
                ),
                Expanded(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Images.ic_app,
                      width: ScreenUtil.screenSize.width * 7 / 30,
                    ),
                    SizedBox(height: 6),
                    Text(
                      APP_TITLE,
                      style: TextStyle(
                        color: ColorConstant.White,
                        fontSize: $(19),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                )),
                Image.asset(
                  Images.launch_branding,
                  width: ScreenUtil.screenSize.width * 0.42,
                ),
              ],
            ).intoContainer(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  Color(0xffFF01FA),
                  Color(0xff0065FF),
                  Color(0xff00F8EF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ))),
    );
  }

  Future<bool> updateByApk({required String url, String name = "app.apk"}) async {
    assert(Platform.isAndroid, "不支持非android平台调用");
    final platform = MethodChannel(PLATFORM_CHANNEL);
    try {
      await platform.invokeMethod('updateAppByApk', {"url": url, "name": name, "desc": S.of(context).downloading});
    } on PlatformException catch (e) {
      LogUtil.e(e, tag: 'DOWNLOAD_APK');
    }
    return Future.value(false);
  }

  Future<bool> installApk({required String fileName}) async {
    assert(Platform.isAndroid, "不支持非android平台调用");
    final platform = MethodChannel(PLATFORM_CHANNEL);
    try {
      await platform.invokeMethod('installAppByApk', {
        "fileName": fileName,
      });
    } on PlatformException catch (e) {
      LogUtil.e(e, tag: 'INSTALL_APK');
    }
    return Future.value(false);
  }
}
