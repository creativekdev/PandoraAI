import 'dart:developer';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cartoonizer/Common/ThemeConstant.dart' as theme;
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
import 'package:flutter_localizations/flutter_localizations.dart';
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
  await MobileAds.instance.initialize();
  await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ['F6236D69A8A84479F17A3C6D0EAB1C53']));
  // run app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  int lastLocaleTime = 0;

  @override
  Widget build(BuildContext context) {
    AppDelegate.instance.init();
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          theme: ThemeData(platform: Platform.isIOS ? TargetPlatform.iOS : TargetPlatform.android),
          title: 'Pandora AI',
          home: MyHomePage(title: 'Pandora AI'),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            var current = DateTime.now().millisecondsSinceEpoch;
            var duration = current - lastLocaleTime;
            if (duration > 200) {
              lastLocaleTime = current;
              debugPrint('deviceLocale: ${deviceLocale!.languageCode}');
              theme.AppContext.currentLocales = deviceLocale.languageCode;
              return deviceLocale;
            } else {
              for (var locale in supportedLocales) {
                if (locale.languageCode == theme.AppContext.currentLocales) {
                  return locale;
                }
              }
            }
            return deviceLocale;
          },
          locale: const Locale('en', 'US'),
          supportedLocales: S.delegate.supportedLocales,
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
  }

  @override
  void dispose() {
    super.dispose();
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
                        S.of(context).new_update_dialog_title,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                          S.of(context).new_update_dialog_content,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black, height: 1.3),
                        ),
                      )
                    ],
                  )),
            ]),
          ),
          confirmText: S.of(context).update_now,
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
      delay(() => openApp(force: true), milliseconds: 5000);
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
                  maintainSize: true,
                  maintainAnimation: true,
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
