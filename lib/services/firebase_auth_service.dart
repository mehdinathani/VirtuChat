import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:virtuchat/app/app.locator.dart';
import 'package:virtuchat/services/firebase_firestore_service.dart';

class FirebaseAuthService with ListenableServiceMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestoreService _firebaseFirestoreService =
      locator<FirebaseFirestoreService>();

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

  Future<void> updateUserDataInFirestore(User user) async {
    try {
      // Create a reference to the users collection in Firestore
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Check if the user document already exists
      final DocumentSnapshot userDocSnapshot =
          await usersCollection.doc(user.uid).get();

      if (!userDocSnapshot.exists) {
        // If the user document doesn't exist, create a new one
        await usersCollection.doc(user.uid).set({
          'uid': user.uid,
          'displayName': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
        });
      } else {
        // If the user document already exists, update the existing data
        await usersCollection.doc(user.uid).update({
          'displayName': user.displayName,
          'photoURL': user.photoURL,
        });
      }
    } catch (e) {
      debugPrint('Error updating user data in Firestore: $e');
      // Handle error, show a snackbar, or a user-friendly message
    }
  }

  Future<void> updateUserProfilePicture(BuildContext context, User user) async {
    // Create a reference to the users collection in Firestore
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    // Check if the user document already exists
    final DocumentSnapshot userDocSnapshot =
        await usersCollection.doc(user.uid).get();
    final picker = ImagePicker();

    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File selectedImage = File(pickedFile.path);
      await usersCollection.doc(user.uid).update({
        'photoURL': selectedImage.path,
      });

      // Update UI with the selected image
    } else {
      // User canceled the image selection
    }
  }

  Future<void> updateUserNameDialog(BuildContext context, User user) async {
    TextEditingController nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Name'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Enter your new name'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  // Create a reference to the users collection in Firestore
                  final CollectionReference usersCollection =
                      FirebaseFirestore.instance.collection('users');

                  // Check if the user document already exists
                  final DocumentSnapshot userDocSnapshot =
                      await usersCollection.doc(user.uid).get();
                  await usersCollection.doc(user.uid).set({
                    'displayName': newName,
                  });

                  Navigator.pop(context); // Close the dialog
                } else {
                  // Handle empty name case, show a message or prevent closing the dialog
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
