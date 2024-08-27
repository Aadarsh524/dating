import 'dart:convert';

import 'package:dating/auth/loginScreen.dart';
import 'package:dating/firebase_options.dart';
import 'package:dating/providers/admin_provider.dart';
import 'package:dating/providers/authentication_provider.dart';
import 'package:dating/providers/chat_provider/call_provider.dart';
import 'package:dating/providers/chat_provider/chat_message_provider.dart';
import 'package:dating/providers/chat_provider/chat_room_provider.dart';
import 'package:dating/providers/dashboard_provider.dart';
import 'package:dating/providers/interaction_provider/favourite_provider.dart';
import 'package:dating/providers/interaction_provider/profile_view_provider.dart';
import 'package:dating/providers/interaction_provider/user_interaction_provider.dart';
import 'package:dating/providers/loading_provider.dart';
import 'package:dating/providers/subscription_provider.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications',
    importance: Importance.high,
    playSound: true);
String type = '';
String roomId = "";
String hostId = "";
bool isMacOs = false;

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
int routeCode = -1;

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Stripe.publishableKey =
    //     "pk_test_51PVaJmAL5L5DqNFSGw0OoujleoUPkpH0nsWCQ1RyVlPruzpInF7Gv9iwtT2qd1WIOB19GJeNLJNeAqOFDidbqI0V00slOhPWCy";
  } else {
    Stripe.publishableKey =
        "pk_test_51PVaJmAL5L5DqNFSGw0OoujleoUPkpH0nsWCQ1RyVlPruzpInF7Gv9iwtT2qd1WIOB19GJeNLJNeAqOFDidbqI0V00slOhPWCy";
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification notification = message.notification!;

    String mainString = message.data.toString();
    String jsonString = mainString.replaceAllMapped(
        RegExp(r'(\w+):'), (match) => '"${match.group(1)}":');
    Map<String, dynamic> messageData = jsonDecode(jsonString);

    if (message.notification != null) {
      // Access the route from the parsed data
      String route = messageData['message']['data']['route'] ?? "/default";

      //If the route is call then we won't display notification. We will navigate to user to a particular screen.
      // This function is called when app is in foreground
      if (route == "/call") {
        roomId = messageData['message']['data']['roomid'];
        hostId = messageData['message']['data']['hostid'];
        navigatorKey.currentState?.pushNamed(route);
      } else {
        //displaying notification
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        FlutterLocalNotificationsPlugin s = FlutterLocalNotificationsPlugin();
        Map<String, dynamic> outerPayload = message.data;
        print(message.data);
        s.show(
          payload: jsonEncode(message.data),
          notification.hashCode,
          notification?.title,
          notification?.body,
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                icon: 'launch_background',
                channelDescription: channel.description,
                importance: Importance.max,
                priority: Priority.high,
                styleInformation: BigTextStyleInformation('')),
          ),
        );
      }
    }
  });

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    switch (notificationResponse.notificationResponseType) {
      // triggers when the notification is tapped
      case NotificationResponseType.selectedNotification:
        if (notificationResponse.payload != null) {
          String jsonString = notificationResponse.payload!.replaceAllMapped(
              RegExp(r'(\w+):'), (match) => '"${match.group(1)}":');

          Map<String, dynamic> outerPayload = jsonDecode(jsonString);

          if (outerPayload.containsKey("message")) {
            Map<String, dynamic> decodedPayload =
                jsonDecode(outerPayload["message"]);

            String token = decodedPayload["token"];
            Map<String, dynamic> data = decodedPayload["data"];

            String route = data["route"];
            roomId = data["roomid"];

            if (route == "/call") {
              navigatorKey.currentState?.pushNamed(route);
            }
          } else {}
        }

        break;
      default:
    }
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {});

  // initialize notification for android
  var initialzationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(
      android: initialzationSettingsAndroid, iOS: initializationSettingsIOS);

  if (!isMacOs) {
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.instance.getInitialMessage().then((message) async {});
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    if (message.data.isNotEmpty) {
      String mainString = message.data.toString();
      String jsonString = mainString.replaceAllMapped(
          RegExp(r'(\w+):'), (match) => '"${match.group(1)}":');
      Map<String, dynamic> messageData = jsonDecode(jsonString);

      String route = messageData['message']['data']['route'] ?? "/default";
      if (route == "/call") {
        roomId = messageData['message']['data']['roomid'];
        navigatorKey.currentState?.pushNamed(route);
      }
    }
  });
  //runApp(const MyApp());
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => UserProfileProvider()),
    ChangeNotifierProvider(create: (_) => LoadingProvider()),
    ChangeNotifierProvider(create: (_) => DashboardProvider()),
    ChangeNotifierProvider(create: (_) => ChatMessageProvider()),
    ChangeNotifierProvider(create: (_) => ChatRoomProvider()),
    ChangeNotifierProvider(create: (_) => UserInteractionProvider()),
    ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
    ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
    ChangeNotifierProvider(create: (_) => CallProvider()),
    ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
    ChangeNotifierProvider(create: (_) => FavouritesProvider()),
    ChangeNotifierProvider(create: (_) => ProfileViewProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor:
          AppColors.backgroundColor, // Color you want for status bar
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return const NeumorphicApp(
      themeMode: ThemeMode.light,
      theme: NeumorphicThemeData(
        baseColor: AppColors.backgroundColor,
        lightSource: LightSource.topLeft,
        depth: 10,
        appBarTheme:
            NeumorphicAppBarThemeData(), // Use NeumorphicAppBarThemeData Explicitly define the AppBarTheme from Flutter
        // Explicitly define the AppBarTheme from Flutter
      ),
      darkTheme: NeumorphicThemeData(
        baseColor: Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        depth: 6,
        appBarTheme:
            NeumorphicAppBarThemeData(), // Use NeumorphicAppBarThemeData Explicitly define the AppBarTheme from Flutter
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
