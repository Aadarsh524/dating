import 'package:dating/helpers/get_server_key.dart';
import 'package:dating/pages/homepage.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StateLoaderPage extends StatelessWidget {
  const StateLoaderPage({Key? key}) : super(key: key);

  Future<void> _fetchData(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userprofileProvider =
          Provider.of<UserProfileProvider>(context, listen: false);
      firebase.User? user = firebase.FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          GetServieKey key = GetServieKey();

          final String token = await key.getServerKeyToken();

          print(token);

          userprofileProvider.getUserProfile(user.uid);
        } catch (e) {
          print("Error fetching user profile: $e");
        }
      } else {
        print("No user is currently logged in");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _fetchData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Delay the navigation to ensure build process is complete
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            });
            return Container();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
