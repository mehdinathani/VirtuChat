import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stacked/stacked.dart';

class FirebaseAuthService with ListenableServiceMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogleNative() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount == null) return null;

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await auth.signInWithCredential(credential);
      return authResult.user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      // Handle error, show a snackbar or a user-friendly message
      return null;
    }
  }

  Future<UserCredential> signInWithGoogleWeb() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider
        .addScope('https://www.googleapis.com/auth/contacts.readonly');
    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);

    // Or use signInWithRedirect
    // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }

  void signinWithGoogle(
      {VoidCallback? onSuccess, VoidCallback? onError}) async {
    try {
      if (kIsWeb) {
        await signInWithGoogleWeb();
      } else {
        await signInWithGoogleNative();
      }
      onSuccess?.call(); // Invoke the callback on success
    } catch (e) {
      print('Error during sign-in: $e');
      onError?.call(); // Invoke the callback on error
    }
  }

  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("Signed in with temporary account.");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  User? getCurrentUser() {
    return auth.currentUser;
  }

  Stream<User?> get onAuthStateChanged {
    return auth.authStateChanges();
  }
}
