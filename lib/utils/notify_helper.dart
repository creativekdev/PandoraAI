import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifyHelper {
  factory NotifyHelper() => _getInstance();

  static NotifyHelper get instance => _getInstance();
  static NotifyHelper? _instance;
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotifyHelper._internal();

  static NotifyHelper _getInstance() {
    _instance ??= NotifyHelper._internal();
    return _instance!;
  }

  Future<void> initializeFirebase() async {
    FirebaseMessaging.onBackgroundMessage((message) async {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    });

    requireFirebasePermission();

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('onNewMessage: ${message.data.toString()}');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              icon: 'ic_launcher', // icon in res/drawable|mipmap
              importance: channel.importance,
            ),
            iOS: IOSNotificationDetails(),
          ),
        );
      }
    });

    FirebaseMessaging.instance.getAPNSToken().then((value) {
      debugPrint('APNS------------------$value');
    });
    FirebaseMessaging.instance.getToken().then((value) {
      debugPrint('Token------------------$value');
    });
  }

  Future<NotificationSettings?> requireFirebasePermission() async {
    if (Platform.isIOS) {
      return FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
    return null;
  }
}
