import 'dart:convert';
import 'dart:developer';
import 'dart:math' as re;
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings setting = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);
    if (setting.authorizationStatus == AuthorizationStatus.authorized) {
      log('User Granted Permission');
    } else if (setting.authorizationStatus == AuthorizationStatus.provisional) {
      log('User Granted provission Permission');
    } else {
      log('User Denied permission');
    }
  }

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/launcher_icon');
    var iosInitializationSettings = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {});
  }

  void firebaseInit(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        log(message.notification!.title.toString());
        log(message.notification!.body.toString());
        //log(message.data.toString());
        // log(message.data["type"]);
      }
      if (Platform.isIOS) {
        foregroundMessage();
      }
      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      } else {
        showNotification(message);
      }
    });
  }

  Future foregroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, sound: true, badge: true);
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        re.Random.secure().nextInt(100000).toString(),
        'High Importance Notifications',
        importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: 'your channel description',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
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
          notificationDetails);
    });
  }

  Future<String?> getDeviceToken() async {
    String? token;
    try {
      if (kIsWeb) {
        token = await FirebaseMessaging.instance.getToken(
            vapidKey: 'BMPINEPL03mORAE60pV7_PadxxkwgCsrlgwPXeXDDSwp_x');
      } else {
        token = await FirebaseMessaging.instance.getToken();
      }

      if (token != null) {
        print("this is the token $token");
      }
    } catch (e) {
      print('Failed to get or save token: $e');
    }
    return token;
  }

  void onTokenRefresh() {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }
}
