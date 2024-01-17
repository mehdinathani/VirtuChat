import 'package:stacked/stacked.dart';

class PromptService with ListenableServiceMixin {
  String _currentPrompt = '';
  String get currentPrompt => _currentPrompt;

  void setCurrentPrompt(String prompt) {
    _currentPrompt = prompt;
    notifyListeners();
  }
}
