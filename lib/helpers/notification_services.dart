import 'dart:developer';
import 'dart:math' as re;
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:dating/pages/call_recieve_screen.dart';
import 'package:dating/pages/homepage.dart';
import 'package:dating/pages/notification_screen.dart';
import 'package:dating/pages/ring_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission(BuildContext context) async {
    NotificationSettings setting = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);
    if (setting.authorizationStatus == AuthorizationStatus.authorized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User Granted Permission'),
        ),
      );
      log('User Granted Permission');
    } else if (setting.authorizationStatus == AuthorizationStatus.provisional) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User Granted provission Permission'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User Denied permission'),
        ),
      );

      Future.delayed(Duration(seconds: 2), () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      handleMessage(context, message);
    });
  }

  void firebaseInit(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? remoteNotification = message.notification;
      AndroidNotification? androidNotification = message.notification!.android;

      if (kDebugMode) {
        log(message.notification!.title.toString());
        log(message.notification!.body.toString());
      }
      if (Platform.isIOS) {
        iosForegroundMessage();
      }
      if (Platform.isAndroid) {
        initLocalNotifications(context, message);

        showNotification(message);
      } else {
        showNotification(message);
      }
    });
  }

  Future iosForegroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, sound: true, badge: true);
  }

  Future<void> setUpInteractMessage(BuildContext context) async {
    //background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessage(context, message);
    });

    //terminated
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message != null && message.data.isNotEmpty) {
          handleMessage(context, message);
        }
      },
    );
  }

  Future<void> handleMessage(
      BuildContext context, RemoteMessage message) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CallRecieveScreen(
                  roomId: message.data['roomid'],
                  name: 'Caller',
                  clientId: '',
                )));
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        message.notification!.android!.channelId.toString(),
        message.notification!.android!.channelId.toString(),
        importance: Importance.max,
        showBadge: true,
        playSound: true);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: 'your channel description',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            ticker: 'ticker');

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          8,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails,
          payload: 'data');
    });
  }

  Future<String?> getDeviceToken() async {
    // ignore: unused_local_variable
    NotificationSettings settings = await messaging.requestPermission(
        alert: true, badge: true, sound: true);
    String? token;
    try {
      if (kIsWeb) {
        token = await messaging.getToken(
            vapidKey: 'BMPINEPL03mORAE60pV7_PadxxkwgCsrlgwPXeXDDSwp_x');
      } else {
        token = await messaging.getToken();
      }

      if (token != null) {
        print("this is the token $token");
      }
    } catch (e) {
      print('Failed to get or save token: $e');
    }
    return token!;
  }

  void onTokenRefresh() {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }
}
