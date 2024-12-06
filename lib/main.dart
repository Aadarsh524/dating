import 'dart:developer';

import 'package:dating/auth/loginScreen.dart';
import 'package:dating/firebase_options.dart';
import 'package:dating/providers/admin_provider.dart';
import 'package:dating/providers/authentication_provider.dart';
import 'package:dating/providers/chat_provider/call_provider.dart';
import 'package:dating/providers/chat_provider/chat_room_provider.dart';
import 'package:dating/providers/chat_provider/socket_message_provider.dart';

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
import 'package:firebase_core/firebase_core.dart' as pre;
import 'package:permission_handler/permission_handler.dart';

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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await pre.Firebase.initializeApp();
  log(message.notification!.title.toString());
  log(message.notification!.body.toString());
  log(message.data.toString());
}

void main() async {
  // In a file like main.dart or a dedicated file for global keys

  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Stripe.publishableKey =
    //     "pk_test_51PVaJmAL5L5DqNFSGw0OoujleoUPkpH0nsWCQ1RyVlPruzpInF7Gv9iwtT2qd1WIOB19GJeNLJNeAqOFDidbqI0V00slOhPWCy";
  } else {
    Stripe.publishableKey =
        "pk_test_51PVaJmAL5L5DqNFSGw0OoujleoUPkpH0nsWCQ1RyVlPruzpInF7Gv9iwtT2qd1WIOB19GJeNLJNeAqOFDidbqI0V00slOhPWCy";
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Permission.notification.isDenied.then(
    (value) {
      if (value) {
        Permission.notification.request();
      }
    },
  );

  //runApp(const MyApp());
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => UserProfileProvider()),
    ChangeNotifierProvider(create: (_) => LoadingProvider()),
    ChangeNotifierProvider(create: (_) => DashboardProvider()),
    ChangeNotifierProvider(
      create: (context) => SocketMessageProvider(),
    ),
    ChangeNotifierProvider(create: (_) => ChatRoomProvider()),
    ChangeNotifierProvider(create: (_) => UserInteractionProvider()),
    ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
    ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
    ChangeNotifierProvider(create: (_) => CallProvider()),
    ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
    ChangeNotifierProvider(create: (_) => FavouritesProvider()),
    ChangeNotifierProvider(create: (_) => ProfileViewProvider()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

    return NeumorphicApp(
      navigatorKey: navigatorKey,
      themeMode: ThemeMode.light,
      theme: const NeumorphicThemeData(
        baseColor: AppColors.backgroundColor,
        lightSource: LightSource.topLeft,
        depth: 10,
        appBarTheme:
            NeumorphicAppBarThemeData(), // Use NeumorphicAppBarThemeData Explicitly define the AppBarTheme from Flutter
        // Explicitly define the AppBarTheme from Flutter
      ),
      darkTheme: const NeumorphicThemeData(
        baseColor: Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        depth: 6,
        appBarTheme:
            NeumorphicAppBarThemeData(), // Use NeumorphicAppBarThemeData Explicitly define the AppBarTheme from Flutter
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
