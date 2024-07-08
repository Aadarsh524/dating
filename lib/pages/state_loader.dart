import 'package:dating/pages/admin/pages/dashboard_page.dart';
import 'package:dating/providers/chat_provider/call_provider.dart';
import 'package:dating/providers/chat_provider/chat_room_provider.dart';
import 'package:dating/providers/dashboard_provider.dart';
import 'package:dating/providers/subscription_provider.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StateLoader extends StatefulWidget {
  const StateLoader({super.key});

  @override
  State<StateLoader> createState() => _StateLoaderState();
}

class _StateLoaderState extends State<StateLoader> {
  bool isApiFetched = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      firebase.User? user = firebase.FirebaseAuth.instance.currentUser;
      await Future.wait([
        context.read<DashboardProvider>().dashboard(1, context),
        context.read<ChatRoomProvider>().fetchChatRoom(context, user!.uid),
        context.read<UserProfileProvider>().getUserProfile(user.uid),
        context.read<SubscriptionProvider>().viewSubcription(),
        // Add more providers here
      ]);
      setState(() {
        isApiFetched = true;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: ((context) => DashboardPage())));
      // Navigate to home screen
    } catch (e) {
      print(e.toString());
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isApiFetched ? Container() : CircularProgressIndicator(),
      ),
    );
  }
}
