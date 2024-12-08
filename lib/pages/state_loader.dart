import 'package:dating/helpers/get_service_key.dart';
import 'package:dating/helpers/notification_services.dart';
import 'package:dating/pages/homepage.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StateLoaderPage extends StatelessWidget {
  const StateLoaderPage({super.key});

  /// Fetches user data and initializes notification services.
  Future<void> _fetchData(BuildContext context) async {
    try {
      final userProfileProvider =
          Provider.of<UserProfileProvider>(context, listen: false);
      final firebase.User? user = firebase.FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint("No user is currently logged in.");
        return;
      }

      final key = GetServieKey();
      final String token = await key.getServerKeyToken();

      final notificationServices = NotificationServices();
      notificationServices.onTokenRefresh(user.uid);

      debugPrint("Service key token: $token");

      // Load the user profile
      await userProfileProvider.getUserProfile(user.uid);
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _fetchData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Navigate after the future completes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            });
            return const SizedBox.shrink();
          } else if (snapshot.hasError) {
            // Handle errors gracefully
            return const Center(
              child: Text(
                'An error occurred. Please try again.',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else {
            // Show loading indicator
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
