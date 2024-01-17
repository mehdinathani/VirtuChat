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
}
