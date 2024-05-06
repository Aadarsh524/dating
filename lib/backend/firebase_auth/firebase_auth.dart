import 'dart:convert';

import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/user_model.dart';
import 'package:dating/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  UserProvider userProvider = UserProvider();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } catch (e) {
      return e.toString(); // Return error message if login fails
    }
  }

  Future<String?> registerWithEmailAndPassword(
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

      final UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        gender: gender,
      );

      // Hit API to store user data in MongoDB
      final response = await http.post(
        Uri.parse('$URI/user'), // Replace with your API endpoint
        body: jsonEncode(newUser.toJson()),
      );

      if (response.statusCode == 200) {
        print(response.statusCode);
        print(response.statusCode);
        print(response.statusCode);
        print(response.statusCode);
        print(response.statusCode);
        print(response.statusCode);
        print(response.statusCode);
        print('User registered and data stored successfully.');
        userProvider.addCurrentUser(newUser.name, newUser.email, newUser.uid);
      } else {
        print('Failed to register user. Error: ${response.statusCode}');
      }

      return null; // Registration successful
    } catch (e) {
      return e.toString(); // Return error message if registration fails
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
          final UserModel newUser = UserModel(
            uid: userCredential.user!.uid,
            name: userCredential.user!.displayName ?? '',
            email: userCredential.user!.email ?? '',
            gender: '',
          );

          // Hit API to store user data in MongoDB
          final response = await http.post(
            Uri.parse('$URI/user'), // Replace with your API endpoint
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(newUser.toJson()),
          );

          if (response.statusCode == 200) {
            print('User registered and data stored successfully.');
            userProvider.addCurrentUser(
                newUser.name, newUser.email, newUser.uid);
          } else {
            print('Failed to register user. Error: ${response.statusCode}');
          }
        }

        // Hit API to store user data in MongoDB
        final response = await http.get(
          Uri.parse(
              '$URI/user/${userCredential.user!.uid}'), // Replace with your API endpoint to fetch user data
        );

        if (response.statusCode == 200) {
          // Parse the response and update the currentUser object
          final Map<String, dynamic> userData = jsonDecode(response.body);

          final UserModel newUser = UserModel(
            uid: userCredential.user!.uid,
            name: '',
            email: '',
            gender: '',
          );
          newUser.name = userData['name'];
          newUser.email = userData['email'];
          newUser.gender = userData['gender'];
        } else {
          // Handle error when user data retrieval fails
          print(
              'Failed to retrieve user data from MongoDB. Error: ${response.statusCode}');
        }

        // Return the user object upon successful sign-in
        return userCredential.user;
      }

      // User canceled Google Sign-In
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
