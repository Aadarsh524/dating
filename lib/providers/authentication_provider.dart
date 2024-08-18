import 'dart:convert';

import 'package:dating/auth/db_client.dart';

import 'package:dating/backend/MongoDB/token_manager.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/providers/admin_provider.dart';
import 'package:dating/providers/chat_provider/chat_room_provider.dart';
import 'package:dating/providers/dashboard_provider.dart';
import 'package:dating/providers/interaction_provider/favourite_provider.dart';
import 'package:dating/providers/interaction_provider/user_interaction_provider.dart';
import 'package:dating/providers/subscription_provider.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Initialize Google Sign-In and Firebase Auth
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  bool _isAuthLoading = false;

  bool get isAuthLoading => _isAuthLoading;

  Future<void> setAuthLoading(bool value) async {
    _isAuthLoading = value;
    notifyListeners();
  }

  Future<bool> checkLoginStatus(BuildContext context) async {
    setAuthLoading(true);
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      setAuthLoading(false);
    }
  }

  Future<String?> signInWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
  ) async {
    setAuthLoading(true);
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        String token = 'demo';
        await TokenManager.saveToken(token);

        return userCredential.user!.uid;
      } else {
        print("Login successful but user object is null");
        return null;
      }
    } catch (e) {
      print("Error during sign in: $e");
      throw e; // Throw the error instead of returning it as a string
    } finally {
      setAuthLoading(false);
    }
  }

  Future<User?> registerWithEmailAndPassword(
    BuildContext context, {
    required String email,
    required String password,
    required String name,
    required String gender,
    required String age,
    required String country,
    required String seekingAgeFrom,
    required String seekingAgeTo,
  }) async {
    setAuthLoading(true);
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        String token = 'demo';

        await TokenManager.saveToken(token);

        bool profileCreated = await _createNewUserProfile(
          userCredential.user!.uid,
          context,
          email: email,
          name: name,
          gender: gender,
          age: age,
          country: country,
          fromAge: seekingAgeFrom,
          toAge: seekingAgeTo,
        );

        if (profileCreated) {
          return userCredential.user;
        } else {
          await signOut();
          clearData(context);
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      // Handle any specific exceptions you want to catch and process
      print(e);
      return null;
    } finally {
      setAuthLoading(false);
      notifyListeners(); // Ensure to notify listeners in the finally block
    }
  }

// Function to sign in with Google and fetch user gender
  Future<User?> signInWithGoogle(BuildContext context) async {
    setAuthLoading(true);
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        if (userCredential.credential != null) {
          if (userCredential.additionalUserInfo?.isNewUser ?? false) {
            // Fetch user gender from Google People API

            await _fetchUserGender(googleSignInAuthentication.accessToken);

            // await _createNewUserProfile(
            //   userCredential.user!.uid,
            //   context,
            //   email: userCredential.user!.email,
            //   gender: gender,
            // ).then((value) {
            //   if (value == true) {
            //     return userCredential.user;
            //   } else {
            //     signOut();
            //     clearData(context);
            //     notifyListeners();
            //     return null;
            //   }
            // });
          } else {
            // Handle case if the user is not new
            return userCredential.user;
          }
        }
      }
      return null;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    } finally {
      setAuthLoading(false);
    }
  }

  // Function to fetch user gender from Google People API
  Future<String> _fetchUserGender(String? accessToken) async {
    if (accessToken == null) return 'Unknown';

    try {
      // Create an authenticated HTTP client
      final client = http.Client();

      // Use the access token to create an authenticated client
      final authHeaders = {'Authorization': 'Bearer $accessToken'};

      final response = await client.get(
        Uri.parse(
            'https://people.googleapis.com/v1/people/me?personFields=genders'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Parse gender information
        final gender = responseData['genders']?.isNotEmpty ?? false
            ? responseData['genders'][0]['value']
            : 'Unknown';

        return gender;
      } else {
        // Handle errors
        print('Failed to fetch user profile: ${response.statusCode}');
        return 'Unknown';
      }
    } catch (e) {
      print('Error fetching user gender: $e');
      return 'Unknown';
    } finally {}
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> clearData(BuildContext context) async {
    var userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    var dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
    var chatRoomProvider =
        Provider.of<ChatRoomProvider>(context, listen: false);
    var subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);

    var favoritesProvider =
        Provider.of<FavouritesProvider>(context, listen: false);
    var userInteractionProvider =
        Provider.of<UserInteractionProvider>(context, listen: false);

    var adminProvider =
        Provider.of<AdminDashboardProvider>(context, listen: false);

    userProfileProvider.clearUserData();
    dashboardProvider.clearUserData();
    chatRoomProvider.clearUserData();
    subscriptionProvider.clearUserData();

    favoritesProvider.clearUserData();
    userInteractionProvider.clearUserData();
    adminProvider.clearUserData();

    notifyListeners();
  }

  Future<bool> _createNewUserProfile(
    String uid,
    BuildContext context, {
    String? name,
    String? email,
    String? gender,
    String? age,
    String? country,
    String? fromAge,
    String? toAge,
  }) async {
    try {
      // Validate token and save it
      String? token = "thisistoken";
      await TokenManager.saveToken(token);

      final newUser = UserProfileModel(
        uid: uid,
        name: name ?? '',
        email: email ?? '',
        gender: gender ?? '',
        age: age ?? '',
        documentStatus: 0,
        country: country ?? '',
        seeking: Seeking(
          fromAge: fromAge ?? 'string',
          toAge: toAge ?? 'string',
          gender: (gender != '' && gender == 'male') ? 'female' : 'male',
        ),
        uploads: [],
        userSubscription: UserSubscription(),
      );

// Add new user to the provider
      final userProfileProvider = context.read<UserProfileProvider>();
      await userProfileProvider.addNewUser(newUser);

      // Save user data in the database
      await DbClient().setData(dbKey: 'uid', value: newUser.uid ?? '');
      await DbClient().setData(dbKey: 'userName', value: newUser.name ?? '');

      return true; // Successful profile creation
    } catch (e) {
      // Handle any errors
      print('Error creating user profile: $e');
      return false; // Profile creation failed
    }
  }
}
