import 'package:dating/pages/homepage.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StateLoaderPage extends StatelessWidget {
  const StateLoaderPage({Key? key}) : super(key: key);

  Future<void> _fetchData(BuildContext context) async {
    firebase.User? user = firebase.FirebaseAuth.instance.currentUser;

    // await context.read<DashboardProvider>().dashboard(1, context);
    // await context.read<ChatRoomProvider>().fetchChatRoom(context, user!.uid);

    await context.read<UserProfileProvider>().getUserProfile(user!.uid);

    // await context.read<SubscriptionProvider>().viewSubcription();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _fetchData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
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
