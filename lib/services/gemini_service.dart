import 'dart:io';

import 'package:google_gemini/google_gemini.dart';
import 'package:virtuchat/app/app.locator.dart';
import 'package:virtuchat/config.dart';
import 'package:virtuchat/services/firebase_auth_service.dart';
import 'package:virtuchat/services/firebase_firestore_service.dart';

class GeminiService {
  final FirebaseFirestoreService _firestoreService =
      locator<FirebaseFirestoreService>();
  final FirebaseAuthService _firebaseAuthService =
      locator<FirebaseAuthService>();
  List<Map<String, dynamic>> chatMessages = [];
  File? imageFile;

  // Create Gemini Instance
  final gemini = GoogleGemini(apiKey: ConfigKeys.apiKey);

  // Text only input

  Future<void> fromText(
      {required String query, required String promptName}) async {
    DateTime now = DateTime.now();
    String timestamp = "${now.hour}:${now.minute}";

    try {
      var value = await gemini.generateFromText(query);
      Map<String, dynamic> geminiMessage = {
        "role": "Gemini",
        "text": value.text,
        "timestamp": timestamp,
        "image": null, // No image for generated text
      };

      // Get the current user UID
      String uid = _firebaseAuthService.getCurrentUser()?.uid ?? '';

      // Store the message in Firestore
      await _firestoreService.addMessage(
          uid, promptName, 'Gemini', value.text, "", 'Gemini', timestamp);
    } catch (error, stackTrace) {
      // Handle errors
      print('Error generating message: $error');
    }
  }

  Future<void> fromTextAndImage(
      {required String query,
      required File image,
      required String promptName}) async {
    DateTime now = DateTime.now();
    String timestamp = "${now.hour}:${now.minute}";
    try {
      var value =
          await gemini.generateFromTextAndImages(query: query, image: image);
      Map<String, dynamic> geminiMessage = {
        "role": "Gemini",
        "text": value.text,
        "timestamp": timestamp,
        "image": null, // No image for generated text
      };

      // Get the current user UID
      String uid = _firebaseAuthService.getCurrentUser()?.uid ?? '';

      // Store the message in Firestore
      await _firestoreService.addMessage(
          uid, promptName, 'Gemini', value.text, "", "Gemini", timestamp);
    } catch (error, stackTrace) {
      // Handle errors
      print('Error generating message: $error');
    }
  }
}
