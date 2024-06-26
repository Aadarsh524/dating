import 'package:dating/auth/loginScreen.dart';
import 'package:dating/firebase_options.dart';
import 'package:dating/providers/chat_provider/chat_message_provider.dart';
import 'package:dating/providers/chat_provider/chat_room_provider.dart';
import 'package:dating/providers/dashboard_provider.dart';
import 'package:dating/providers/interaction_provider/user_interaction_provider.dart';
import 'package:dating/providers/loading_provider.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      "pk_test_51PVaJmAL5L5DqNFSGw0OoujleoUPkpH0nsWCQ1RyVlPruzpInF7Gv9iwtT2qd1WIOB19GJeNLJNeAqOFDidbqI0V00slOhPWCy";
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => UserProfileProvider()),
    ChangeNotifierProvider(create: (_) => LoadingProvider()),
    ChangeNotifierProvider(create: (_) => DashboardProvider()),
    ChangeNotifierProvider(create: (_) => ChatMessageProvider()),
    ChangeNotifierProvider(create: (_) => ChatRoomProvider()),
    ChangeNotifierProvider(create: (_) => UserInteractionProvider()),
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
