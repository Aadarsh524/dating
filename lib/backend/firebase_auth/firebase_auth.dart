import 'package:dating/auth/db_client.dart';
import 'package:dating/backend/MongoDB/apis.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/providers/loading_provider.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class AuthService {
  ApiClient apiClient = ApiClient();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? users = FirebaseAuth.instance.currentUser;

  Future<String?> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await context
          .read<UserProfileProvider>()
          .getUserData(userCredential.user!.uid)
          .then((value) async {
        if (value != null) {
          Provider.of<UserProfileProvider>(context, listen: false)
              .setCurrentUserProfile(value);
          await DbClient().setData(dbKey: "uid", value: value.uid ?? '');
          await DbClient().setData(dbKey: "userName", value: value.name ?? '');

          await DbClient().setData(dbKey: "email", value: value.email ?? '');
        }
      });

      return userCredential.user?.uid;
    } catch (e) {
      return e.toString(); // Return error message if login fails
    }
  }

  Future<bool> registerWithEmailAndPassword(BuildContext context,
      {required String email,
      required String password,
      required String name,
      required String gender,
      required String age}) async {
    context.read<LoadingProvider>().setLoading(true);

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
        seeking: Seeking(age: '', gender: ''),
        uploads: [],
      );
      await context.read<UserProfileProvider>().addNewUser(newUser, context);

      await DbClient().setData(dbKey: "uid", value: newUser.uid ?? '');
      await DbClient().setData(dbKey: "userName", value: newUser.name ?? '');
      await DbClient().setData(dbKey: "email", value: newUser.email ?? '');

      return true;
    } catch (e) {
      return false;
    } finally {
      context.read<LoadingProvider>().setLoading(false);
    }
  }

  Future<User?> signInWithGoogle(BuildContext context) async {
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
            name: '',
            email: '',
            gender: '',
            image: '',
            age: '',
            bio: '',
            address: '',
            interests: '',
            seeking: Seeking(age: '', gender: ''),
            uploads: [],
          );
          await context
              .read<UserProfileProvider>()
              .addNewUser(newUser, context);

          await DbClient().setData(dbKey: "uid", value: newUser.uid ?? '');
          await DbClient()
              .setData(dbKey: "userName", value: newUser.name ?? '');
          await DbClient().setData(dbKey: "email", value: newUser.email ?? '');
        }

        await context
            .read<UserProfileProvider>()
            .getUserData(userCredential.user!.uid)
            .then((value) async {
          if (value != null) {
            Provider.of<UserProfileProvider>(context, listen: false)
                .setCurrentUserProfile(value);
            await DbClient().setData(dbKey: "uid", value: value.uid ?? '');
            await DbClient()
                .setData(dbKey: "userName", value: value.name ?? '');

            await DbClient().setData(dbKey: "email", value: value.email ?? '');
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
