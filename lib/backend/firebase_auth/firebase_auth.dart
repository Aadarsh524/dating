import 'dart:convert';
import 'dart:developer';

import 'package:dating/auth/db_client.dart';
import 'package:dating/backend/MongoDB/apis.dart';
import 'package:dating/datamodel/user_profile_provider.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  UserProfileProvider userProfileProvider = UserProfileProvider();
  ApiClient apiClient = ApiClient();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  getUid() {
    User? users = FirebaseAuth.instance.currentUser;
    return users!.uid;
  }

  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      log("uid:${userCredential.user!.uid}");

      apiClient
          .getUserProfileDataMobile(userCredential.user!.uid)
          .then((value) async {
        if (value != null) {
          final Map<String, dynamic> userData = jsonDecode(value);

          final UserProfileModel newUser = UserProfileModel(
            uid: userData['uid'],
            name: userData['name'],
            email: userData['email'],
            gender: userData['gender'],
            image: userData['image'],
            address: userData['address'],
            age: userData['age'],
            bio: userData['bio'],
            interests: userData['interests'],
            uploads: userData['uploads'],
            seeking: userData['seeking'],
          );

          print(newUser.email);

          userProfileProvider.setCurrentUserProfile(newUser);

          await DbClient().setData(dbKey: "uid", value: newUser.uid);
          await DbClient().setData(dbKey: "userName", value: newUser.name);
          await DbClient().setData(dbKey: "gender", value: newUser.gender);
          await DbClient().setData(dbKey: "email", value: newUser.email);
        }
      });

      return userCredential.user?.uid;
    } catch (e) {
      return e.toString(); // Return error message if login fails
    }
  }

  Future registerWithEmailAndPassword(
      {required String email,
      required String password,
      required String name,
      required String gender,
      required String age}) async {
    try {
      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final UserProfileModel newUser = UserProfileModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        gender: gender,
        image: '',
        age: age,
        bio: '',
        address: '',
        interests: '',
        seeking: {},
        uploads: [],
      );

      await DbClient().setData(dbKey: "uid", value: newUser.uid);
      await DbClient().setData(dbKey: "userName", value: newUser.name);
      await DbClient().setData(dbKey: "gender", value: newUser.gender);
      await DbClient().setData(dbKey: "email", value: newUser.email);

      apiClient.postUserProfileDataMobile(newUser).then(
            (value) => {
              if (value == true)
                {userProfileProvider.setCurrentUserProfile(newUser)}
            },
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        // Obtain the GoogleSignInAuthentication object
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        // Create a new credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in to Firebase with the Google credentials
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        // Check if the user is signing in for the first time
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          final UserProfileModel newUser = UserProfileModel(
            uid: userCredential.user!.uid,
            name: userCredential.user!.displayName ?? '',
            email: userCredential.user!.email ?? '',
            gender: '',
            image: '',
            address: '',
            age: '',
            bio: '',
            interests: '',
            seeking: {},
            uploads: [],
          );

          apiClient.postUserProfileDataMobile(newUser).then(
                (value) => {
                  if (value == true)
                    {userProfileProvider.setCurrentUserProfile(newUser)}
                },
              );
        }

        apiClient
            .getUserProfileDataMobile(userCredential.user!.uid)
            .then((value) async {
          if (value != null) {
            final Map<String, dynamic> userData = jsonDecode(value);

            final UserProfileModel newUser = UserProfileModel(
              uid: userData['uid'],
              name: userData['name'],
              email: userData['email'],
              gender: userData['gender'],
              image: userData['image'],
              address: userData['address'],
              age: userData['age'],
              bio: userData['bio'],
              interests: userData['interests'],
              uploads: userData['uploads'],
              seeking: userData['seeking'],
            );

            userProfileProvider.setCurrentUserProfile(newUser);
            await DbClient().setData(dbKey: "uid", value: newUser.uid);
            await DbClient().setData(dbKey: "userName", value: newUser.name);
            await DbClient().setData(dbKey: "gender", value: newUser.gender);
            await DbClient().setData(dbKey: "email", value: newUser.email);
          }
        });

        return userCredential.user;
      }

      return null;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null; // Return null if sign-in fails
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
