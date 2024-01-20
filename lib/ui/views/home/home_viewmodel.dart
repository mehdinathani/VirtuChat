import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtuchat/app/app.bottomsheets.dart';
import 'package:virtuchat/app/app.dialogs.dart';
import 'package:virtuchat/app/app.locator.dart';
import 'package:virtuchat/app/app.router.dart';
import 'package:virtuchat/services/firebase_auth_service.dart';
import 'package:virtuchat/services/firebase_firestore_service.dart';
import 'package:virtuchat/services/prompt_service.dart';
import 'package:virtuchat/ui/common/app_strings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _navigationService = locator<NavigationService>();
  final _firestoreStoreService = locator<FirebaseFirestoreService>();
  final _firebaseAuthService = locator<FirebaseAuthService>();
  final _promptService = locator<PromptService>();
  String currentUserName = '';
  String currentUserDPUrl = "";
  String currentUserEmail = "";
  late User user;

  List<String> _promptList = []; // Add this list to store prompts
  List<String> get promptList => _promptList;

  String get counterLabel => 'Counter is: $_counter';

  int _counter = 0;

  void incrementCounter() {
    _counter++;
    rebuildUi();
  }

  void showBottomSheet() {
    _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: ksHomeBottomSheetTitle,
      description: ksHomeBottomSheetDescription,
    );
  }

  jumpToLogin() {
    _navigationService.navigateToLoginView();
  }

  // void showDialog() {
  //   _dialogService.showCustomDialog(
  //     variant: DialogType.infoAlert,
  //     title: 'Stacked Rocks!',
  //     description: 'Give stacked $_counter stars on Github',
  //   );
  // }

  void showAddPromptDialog(BuildContext context) {
    TextEditingController _textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Prompt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter the name for your new prompt:'),
              TextField(
                controller: _textFieldController,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String newPromptName = _textFieldController.text.trim();
                if (newPromptName.isNotEmpty) {
                  _addPrompt(newPromptName);
                  Navigator.pop(context);
                }
              },
              child: Text('Create'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addPrompt(String promptName) async {
    try {
      String uid = _firebaseAuthService.auth.currentUser?.uid ?? '';
      if (uid.isNotEmpty) {
        rebuildUi(); // Notify UI to rebuild while fetching from Firebase
        await _firestoreStoreService.createPrompt(uid, promptName);
      } else {
        // Handle the case where UID is null or empty
        debugPrint('Error: User UID is null or empty.');
      }
    } catch (e) {
      // Handle Firestore operation errors
      debugPrint('Error adding prompt: $e');
    }
  }

  Stream<List<String>> getPrompts() {
    String uid = _firebaseAuthService.auth.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      return _firestoreStoreService.getPrompts(uid);
    } else {
      // Handle the case where UID is null or empty
      debugPrint('Error: User UID is null or empty.');
      return Stream.value([]); // Return an empty stream
    }
  }

  navigateToGeminiChat() async {
    await _navigationService.navigateToGeminichatView();
  }

  updateCurrentPrompt(String prompt) {
    _promptService.setCurrentPrompt(prompt);
  }

  deletePrompt(promptName) {
    String uid = _firebaseAuthService.auth.currentUser?.uid ?? '';
    _firestoreStoreService.deletePrompt(uid, promptName);
  }

  logout() {
    _firebaseAuthService.signOut();
    _navigationService.navigateToLoginView();
  }

  updateCurrentUSerData() async {
    user = _firebaseAuthService.auth.currentUser!;
    if (user != null) {
      // Fetch user details from Firestore using the UID
      DocumentSnapshot userDoc =
          await _firestoreStoreService.getUserDoc(user.uid);

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        currentUserName = userData['displayName'] ?? "User";
        currentUserDPUrl = userData['photoURL'] ?? "";
        currentUserEmail = userData['email'] ?? "";

        rebuildUi();
      }
    }
  }

  updateCurrentUsername(context) async {
    setBusy(true);
    user = _firebaseAuthService.auth.currentUser!;
    await _firebaseAuthService.updateUserNameDialog(context, user);
    setBusy(false);
    rebuildUi();
  }

  updateCurrentDP(context) async {
    user = _firebaseAuthService.auth.currentUser!;
    await _firebaseAuthService.updateUserProfilePicture(context, user);
    rebuildUi();
  }

  init() {
    updateCurrentUSerData();
  }
}
