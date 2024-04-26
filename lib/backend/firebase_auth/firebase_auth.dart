import 'package:dating/backend/MongoDB/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final MongoDatabase mongoDatabase = MongoDatabase();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // No error, login successful
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
      // Store additional user information in Firestore

      await mongoDatabase.sendUserDataToServer({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
        'name': name,
        'gender': gender,
        'age': age,
      });

      // Update user display name
      await userCredential.user!.updateDisplayName(name);

      // You can also store additional user information in Firestore or Realtime Database
      // For simplicity, I'm just updating the display name here
      // You can create a Firestore service to handle storing user data

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
          await mongoDatabase.sendUserDataToServer({
            'uid': userCredential.user!.uid,
            'email': userCredential.user!.email,
            'name': '',
            'gender': '',
            'age': '',
          });
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