import 'package:dating/auth/db_client.dart';
import 'package:dating/backend/MongoDB/apis.dart';
import 'package:dating/backend/MongoDB/token_manager.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
        String token = await ApiClient().validateToken() ?? '';
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
  }) async {
    setAuthLoading(true);
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String token = await ApiClient().validateToken() ?? '';
      await TokenManager.saveToken(token);

      if (userCredential.user != null) {
        await _createNewUserProfile(
          userCredential.user!.uid,
          context,
          name: name,
          email: email,
          gender: gender,
          age: age,
        ).then((value) {
          if (value == true) {
            return userCredential.user;
          } else {
            signOut();
            notifyListeners();
            return false;
          }
        });
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      setAuthLoading(false);
    }
    return null;
  }

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
            await _createNewUserProfile(userCredential.user!.uid, context,
                    email: userCredential.user!.email)
                .then((value) {
              if (value == true) {
                return userCredential.user;
              } else {
                signOut();
                notifyListeners();
                return false;
              }
            });
          }
        }

        return userCredential.user;
      }
      return null;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null; // Return null if sign-in fails
    } finally {
      setAuthLoading(false);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
    await _auth.signOut();
    notifyListeners();
  }

  // Future<void> _initializeUserProfile(String uid, BuildContext context) async {
  //   final userProfileProvider = context.read<UserProfileProvider>();
  //   final userProfile = await userProfileProvider.getUserProfile(uid);

  //   if (userProfile != null) {
  //     userProfileProvider.setCurrentUserProfile(userProfile);

  //     await DbClient().setData(dbKey: "uid", value: userProfile.uid ?? '');
  //     await DbClient()
  //         .setData(dbKey: "userName", value: userProfile.name ?? '');
  //     // await DbClient().setData(dbKey: "email", value: userProfile.email ?? '');
  //   }
  // }

  Future<bool> _createNewUserProfile(String uid, BuildContext context,
      {String? name,
      String? email,
      String? gender,
      String? age,
      String? fromAge,
      String? toAge}) async {
    try {
      // Validate token and save it
      String? token = await ApiClient().validateToken();
      if (token != null) {
        await TokenManager.saveToken(token);
      } else {
        print('Token validation failed');
        return false; // Token validation failed
      }

      // Create new user profile
      final newUser = UserProfileModel(
        uid: uid,
        name: name ?? '',
        email: email ?? '',
        gender: gender ?? '',
        age: age ?? '',
        documentStatus: 1,
        seeking: Seeking(
          fromAge: fromAge ?? 'string',
          toAge: toAge ?? 'string',
          gender: (gender != '' && gender == 'male') ? 'Female' : 'male',
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
