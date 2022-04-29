// import 'package:flutter/foundation.dart';
// import 'package:appsflyer_sdk/appsflyer_sdk.dart';

// import 'config.dart';

// class AppsflyerEvent {
//   static String open_app = "open app";
//   static String click_login = "click login";
//   static String click_signup = "click signup";
//   static String click_cartoon = "click cartoon";
//   static String click_share = "click share";
//   static String click_download = "click download";
//   static String click_pay = "click pay";
//   static String click_choose_photo = "click choose photo";
//   static String click_take_a_selfie = "click choose photo";
// }

// class Appsflyer {
//   Appsflyer._init();

//   static AppsflyerSdk? _instance;

//   static AppsflyerSdk get instance {
//     _instance ??= _initSdk();
//     return _instance!;
//   }

//   static AppsflyerSdk _initSdk() {
//     AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
//       afDevKey: Config.instance.appsflyerKey,
//       appId: IOS_APP_ID,
//       showDebug: kDebugMode,
//       timeToWaitForATTUserAuthorization: 60, // for iOS 14.5
//       // appInviteOneLink: oneLinkID, // Optional field
//       disableAdvertisingIdentifier: false, // Optional field
//       disableCollectASA: false,
//     ); // Optional field

//     AppsflyerSdk appsflyerSdk = AppsflyerSdk(appsFlyerOptions);

//     appsflyerSdk.onAppOpenAttribution((res) {
//       print("onAppOpenAttribution res: " + res.toString());
//     });
//     appsflyerSdk.onInstallConversionData((res) {
//       print("onInstallConversionData res: " + res.toString());
//     });
//     appsflyerSdk.onDeepLinking((DeepLinkResult dp) {
//       switch (dp.status) {
//         case Status.FOUND:
//           print(dp.deepLink?.toString());
//           print("deep link value: ${dp.deepLink?.deepLinkValue}");
//           break;
//         case Status.NOT_FOUND:
//           print("deep link not found");
//           break;
//         case Status.ERROR:
//           print("deep link error: ${dp.error}");
//           break;
//         case Status.PARSE_ERROR:
//           print("deep link status parsing error");
//           break;
//       }
//       print("onDeepLinking res: " + dp.toString());
//     });

//     appsflyerSdk.initSdk(registerConversionDataCallback: true, registerOnAppOpenAttributionCallback: true, registerOnDeepLinkingCallback: true);
//     return appsflyerSdk;
//   }

//   static Future<bool?> logEvent(String eventName, {Map? eventValues}) async {
//     bool? result;
//     result = await _instance?.logEvent(eventName, null);
//     return result;
//   }
// }
