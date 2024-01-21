import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:virtuchat/app/app.locator.dart';
import 'package:virtuchat/services/firebase_auth_service.dart';
import 'package:virtuchat/services/firebase_firestore_service.dart';
import 'package:virtuchat/services/gemini_service.dart';
import 'package:virtuchat/services/prompt_service.dart';

class GeminichatViewModel extends BaseViewModel {
  final FocusNode messageFocusNode = FocusNode();

  TextEditingController usermsg = TextEditingController();
  final _firebaseAuthService = locator<FirebaseAuthService>();
  final _firestoreService = locator<FirebaseFirestoreService>();
  final _promptService = locator<PromptService>();
  final _geminiService = locator<GeminiService>();
  File? imageFile;
  String imageUrl = "";
  String currentUserName = '';
  String currentUserDPUrl = "";
  String currentUserEmail = "";
  late User user;

  final ScrollController controller = ScrollController();

  List<Map<String, dynamic>> _chatMessages = [];
  List<Map<String, dynamic>> get chatMessages => _chatMessages;

  String _promptName = "";
  String get promptName {
    _promptName = _promptService.currentPrompt;
    return _promptName;
  }

  initialize(String promptName) {
    _promptName = promptName;
    updateCurrentUSerData();
    // Load chat messages from Firebase
    loadChatMessages(currentPrompt);
    debugPrint("initialized");
    _loadChatMessages();
  }

  String _currentPrompt = ''; // Store the current prompt name
  String get currentPrompt {
    return _promptService.currentPrompt;
  }

  // Load chat messages from Firebase for the specified prompt
  void loadChatMessages(String promptName) {
    _currentPrompt = _promptService.currentPrompt;
    try {
      _currentPrompt = promptName;
      String uid = _firebaseAuthService.auth.currentUser!.uid;
      _firestoreService.getMessages(uid, _promptName).listen((messages) {
        _chatMessages = messages.reversed.toList();
        rebuildUi();
      });
    } catch (e) {
      // Handle errors
      print('Error loading chat messages: $e');
    }
  }

  // // Add a message to the chat
  // Future<void> addMessage(String message) async {
  //   String uid = _firebaseAuthService.auth.currentUser!.uid;
  //   await _firestoreService.addMessage(uid, _promptName, uid, message);
  //   // Reload chat messages after adding a new message
  //   _loadChatMessages();
  // }

  // Load chat messages from Firebase
  void _loadChatMessages() {
    String uid = _firebaseAuthService.auth.currentUser!.uid;
    _firestoreService.getMessages(uid, _promptName).listen(
      (messages) {
        _chatMessages = messages.reversed.toList();
        rebuildUi();
      },
      onError: (error) {
        // Handle errors during message loading
        print('Error loading chat messages: $error');
      },
    );
  }

  sendMessageOnlyText(String query) async {
    setBusy(true);
    // Add the user's message to Firebase Firestore
    await addMessage(query, "User");

    // Use the GeminiService to generate a response and add it to Firebase Firestore
    await _geminiService.fromText(query: query, promptName: currentPrompt);
    setBusy(false);
  }

  sendMessagewithImage(String query) async {
    setBusy(true);
    // Add the user's message to Firebase Firestore
    await addMessage(query, "User");

    // Use the GeminiService to generate a response and add it to Firebase Firestore
    await _geminiService.fromTextAndImage(
        query: query, image: imageFile!, promptName: currentPrompt);
    setBusy(false);
  }

// Helper method to add the user's message to Firebase Firestore
  Future<void> addMessage(String message, role) async {
    DateTime now = DateTime.now();
    String timestamp =
        "${now.day}/${now.month} ${now.hour}:${now.minute}:${now.millisecond}";

    try {
      // Get the current user's UID
      String uid = _firebaseAuthService.auth.currentUser!.uid;
      print('UID: $uid');
      print('PromptName: ${currentPrompt}');
      debugPrint("role : $role");

      // Add the user's message to Firebase Firestore
      await _firestoreService.addMessage(
          uid, currentPrompt, uid, message, imageUrl, role, timestamp);

      // Reload chat messages after adding a new message
      _loadChatMessages();
    } catch (e) {
      // Handle errors
      print('Error adding user message: $e');
    }
  }

  void scrollToTheEnd() {
    controller.jumpTo(controller.position.maxScrollExtent);
  }

  uploadImageToFirestorega() async {
    imageUrl = await _firestoreService.uploadImage(imageFile!);
  }

  getImagePath() {
    imageUrl = imageFile!.path;
    debugPrint("ImageUrl: $imageUrl");
  }

  updateImageFile(File image) {
    imageFile = image;
    rebuildUi();
  }

  Alignment calculateMessageAlignment(int index) {
    return chatMessages[index]["role"] == "User"
        ? Alignment.centerLeft
        : Alignment.centerRight;
  }

  updateCurrentUSerData() async {
    user = _firebaseAuthService.auth.currentUser!;
    if (user != null) {
      // Fetch user details from Firestore using the UID
      DocumentSnapshot userDoc = await _firestoreService.getUserDoc(user.uid);

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        currentUserName = userData['displayName'] ?? "User";
        currentUserDPUrl = userData['photoURL'] ?? "";
        currentUserEmail = userData['email'] ?? "";

        rebuildUi();
      }
    }
  }
}
