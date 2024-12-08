import 'package:dating/auth/loginDesktop/login.dart';
import 'package:dating/auth/loginMobile/login.dart';
import 'package:dating/helpers/notification_services.dart';
import 'package:dating/pages/state_loader.dart';
import 'package:dating/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isUserLoggedIn = false;
  bool _isSavedToLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeNotificationServices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  /// Initializes notification services
  void _initializeNotificationServices() {
    final notificationServices = NotificationServices();
    notificationServices.firebaseInit(context);
  }

  /// Checks login status and updates the state accordingly
  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isSavedToLoggedIn = prefs.getBool('isSavedToLoggedIn') ?? false;

      if (_isSavedToLoggedIn) {
        final isUserLoggedIn = await context
            .read<AuthenticationProvider>()
            .checkLoginStatus(context);

        setState(() {
          _isUserLoggedIn = isUserLoggedIn;
        });
      } else {
        await _handleLogout();
      }
    } catch (e) {
      debugPrint("Error checking login status: $e");
    }
  }

  /// Handles logout by signing out and clearing data
  Future<void> _handleLogout() async {
    try {
      final authProvider = context.read<AuthenticationProvider>();
      await authProvider.signOut();
      await authProvider.clearData(context);
    } catch (e) {
      debugPrint("Error during logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUserLoggedIn) {
      return const StateLoaderPage();
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return constraints.maxWidth < 600
                  ? const LoginMobile() // Mobile view
                  : const LoginDesktop(); // Desktop view
            },
          ),
        ),
      ),
    );
  }
}
