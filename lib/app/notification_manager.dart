import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/firebase_options.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/push_extra_entity.dart';
import 'package:cartoonizer/views/msg/msg_list_controller.dart';
import 'package:cartoonizer/views/msg/msg_list_screen.dart';
import 'package:cartoonizer/views/transfer/cartoonize.dart';
import 'package:common_utils/common_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
bool _isFlutterLocalNotificationsInitialized = false;
late AndroidNotificationChannel _channel;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    name: 'cartoonizer',
  );
  await setupFlutterNotifications();
  _showNotification(message);
  LogUtil.d('Handling a background message ${message.data}');
}

class NotificationManager extends BaseManager {
  late CacheManager cacheManager;

  @override
  Future<void> onCreate() async {
    await super.onCreate();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    requireFirebasePermission();
    await setupFlutterNotifications();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LogUtil.d('onNewMessage: ${message.data.toString()}');
      _showNotification(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      LogUtil.d('onNewMessageOpenedApp: ${message.data.toString()}');
      onHandleNotificationClick(message);
    });
    FirebaseMessaging.instance.getAPNSToken().then((value) {
      LogUtil.d('APNS------------------$value');
    });
  }

  @override
  Future<void> onAllManagerCreate() async {
    cacheManager = getManager();
    FirebaseMessaging.instance.getToken().then((value) {
      LogUtil.d('Token------------------$value');
      cacheManager.setString(CacheManager.pushToken, value);
    }).onError((error, stackTrace) {
      LogUtil.e("Token get failed: ${error}");
    });
  }

  Future<NotificationSettings?> requireFirebasePermission() async {
    if (Platform.isIOS) {
      return FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
    return null;
  }

  ///
  /// 调用通知栏
  Future<void> showCustomNotification() async {
    var android = new AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      priority: Priority.high,
      importance: Importance.high,
      color: ColorConstant.BlueColor,
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    return _flutterLocalNotificationsPlugin.show(
      1,
      '测试',
      '内容',
      platform,
    );
  }

  Future<void> onHandleNotificationClick(RemoteMessage message) async {
    if (message.data.containsKey('tab')) {
      Navigator.popUntil(Get.context!, ModalRoute.withName('/HomeScreen'));
      var pushExtraEntity = PushExtraEntity.fromJson(message.data);
      EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.HOME.id()]));
      // EventBusHelper().eventBus.fire(OnEffectPushClickEvent(data: pushExtraEntity));
      if (TextUtil.isEmpty(pushExtraEntity.tab)) return;
      if (TextUtil.isEmpty(pushExtraEntity.category)) return;
      EffectDataController controller = Get.find<EffectDataController>();
      var pos = controller.findItemPos(pushExtraEntity.tab, pushExtraEntity.category, pushExtraEntity.effect);
      Cartoonize.open(
        Get.context!,
        source: 'push_click',
        tabPos: pos.tabPos,
        itemPos: pos.itemPos,
        categoryPos: pos.categoryPos,
      );
    } else {
      Navigator.popUntil(Get.context!, ModalRoute.withName('/HomeScreen'));
      try {
        Get.find<MsgListController>();
      } catch (e) {
        Get.put(MsgListController());
      }
      if (Get.context != null) {
        MsgListScreen.push(Get.context!);
      }
    }
    return null;
  }
}

Future<void> onSelectNotification(String? payload) async {
  LogUtil.d(payload, tag: 'notify-payload');
  try {
    Get.find<MsgListController>();
  } catch (e) {
    Get.put(MsgListController());
  }
  if (Get.context != null) {
    MsgListScreen.push(Get.context!);
  }
}

Future<void> setupFlutterNotifications() async {
  if (_isFlutterLocalNotificationsInitialized) {
    return;
  }
  _channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  var android = AndroidInitializationSettings('@mipmap/ic_launcher_small');
  var ios = IOSInitializationSettings();
  var initSettings = InitializationSettings(android: android, iOS: ios);
  _flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: onSelectNotification);

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  _isFlutterLocalNotificationsInitialized = true;
}

Future<void> _showNotification(RemoteMessage message) async {
  if (!AppDelegate.instance.getManager<UserManager>().isNeedLogin) {
    AppDelegate.instance.getManager<MsgManager>().loadMsgList(page: 0, pageSize: 1, actions: []);
  }
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = notification?.android;
  AppleNotification? apple = notification?.apple;
  if (notification == null) {
    return;
  }
  if (android != null) {
    if (android.imageUrl != null && android.imageUrl!.isNotEmpty) {
      _showBigPictureNotificationHiddenLargeIcon(notification);
    } else {
      _showNotificationDefault(notification);
    }
  } else {
    // if (apple != null) {
    //   if (apple.imageUrl != null && apple.imageUrl!.isNotEmpty) {
    //     _showNotificationWithAttachment(notification);
    //   } else {
    //     _showNotificationDefault(notification);
    //   }
    // }
  }
}

/// normal notification
void _showNotificationDefault(RemoteNotification notification) {
  _flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: _channel.importance,
      ),
    ),
  );
}

/// image on Android
Future<void> _showBigPictureNotificationHiddenLargeIcon(
  RemoteNotification notification,
) async {
  final String largeIconPath = await _downloadAndSaveFile(notification.android!.imageUrl!, 'largeIcon');
  final String bigPicturePath = await _downloadAndSaveFile(notification.android!.imageUrl!, 'bigPicture');
  final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
    FilePathAndroidBitmap(bigPicturePath),
    hideExpandedLargeIcon: true,
    contentTitle: notification.title,
    htmlFormatContentTitle: true,
    summaryText: notification.body,
    htmlFormatSummaryText: true,
  );
  final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    _channel.id,
    _channel.name,
    channelDescription: _channel.description,
    largeIcon: FilePathAndroidBitmap(largeIconPath),
    styleInformation: bigPictureStyleInformation,
  );
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  await _flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    platformChannelSpecifics,
  );
}

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  Directory directory = AppDelegate.instance.getManager<CacheManager>().storageOperator.pushDir;
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

/// image on iOS
Future<void> _showNotificationWithAttachment(RemoteNotification notification) async {
  final String bigPicturePath = await _downloadAndSaveFile(notification.apple!.imageUrl!, 'bigPicture.jpg');
  final IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails(attachments: <IOSNotificationAttachment>[IOSNotificationAttachment(bigPicturePath)]);

  final MacOSNotificationDetails macOSPlatformChannelSpecifics = MacOSNotificationDetails(attachments: <MacOSNotificationAttachment>[MacOSNotificationAttachment(bigPicturePath)]);
  final NotificationDetails notificationDetails = NotificationDetails(
    iOS: iOSPlatformChannelSpecifics,
    macOS: macOSPlatformChannelSpecifics,
  );
  await _flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    notificationDetails,
  );
}
