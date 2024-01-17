import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:virtuchat/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:virtuchat/services/gemini_service.dart';
import 'package:virtuchat/services/firebase_auth_service.dart';
import 'package:virtuchat/services/firebase_firestore_service.dart';
import 'package:virtuchat/services/prompt_service.dart';
// @stacked-import

import 'test_helpers.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<NavigationService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<BottomSheetService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<DialogService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<GeminiService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<FirebaseAuthService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<FirebaseFirestoreService>(
      onMissingStub: OnMissingStub.returnDefault),
  MockSpec<PromptService>(onMissingStub: OnMissingStub.returnDefault),
// @stacked-mock-spec
])
void registerServices() {
  getAndRegisterNavigationService();
  getAndRegisterBottomSheetService();
  getAndRegisterDialogService();
  getAndRegisterGeminiService();
  getAndRegisterFirebaseAuthService();
  getAndRegisterFirebaseFirestoreService();
  getAndRegisterPromptService();
// @stacked-mock-register
}

MockNavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

MockBottomSheetService getAndRegisterBottomSheetService<T>({
  SheetResponse<T>? showCustomSheetResponse,
}) {
  _removeRegistrationIfExists<BottomSheetService>();
  final service = MockBottomSheetService();

  when(service.showCustomSheet<T, T>(
    enableDrag: anyNamed('enableDrag'),
    enterBottomSheetDuration: anyNamed('enterBottomSheetDuration'),
    exitBottomSheetDuration: anyNamed('exitBottomSheetDuration'),
    ignoreSafeArea: anyNamed('ignoreSafeArea'),
    isScrollControlled: anyNamed('isScrollControlled'),
    barrierDismissible: anyNamed('barrierDismissible'),
    additionalButtonTitle: anyNamed('additionalButtonTitle'),
    variant: anyNamed('variant'),
    title: anyNamed('title'),
    hasImage: anyNamed('hasImage'),
    imageUrl: anyNamed('imageUrl'),
    showIconInMainButton: anyNamed('showIconInMainButton'),
    mainButtonTitle: anyNamed('mainButtonTitle'),
    showIconInSecondaryButton: anyNamed('showIconInSecondaryButton'),
    secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
    showIconInAdditionalButton: anyNamed('showIconInAdditionalButton'),
    takesInput: anyNamed('takesInput'),
    barrierColor: anyNamed('barrierColor'),
    barrierLabel: anyNamed('barrierLabel'),
    customData: anyNamed('customData'),
    data: anyNamed('data'),
    description: anyNamed('description'),
  )).thenAnswer((realInvocation) =>
      Future.value(showCustomSheetResponse ?? SheetResponse<T>()));

  locator.registerSingleton<BottomSheetService>(service);
  return service;
}

MockDialogService getAndRegisterDialogService() {
  _removeRegistrationIfExists<DialogService>();
  final service = MockDialogService();
  locator.registerSingleton<DialogService>(service);
  return service;
}

MockGeminiService getAndRegisterGeminiService() {
  _removeRegistrationIfExists<GeminiService>();
  final service = MockGeminiService();
  locator.registerSingleton<GeminiService>(service);
  return service;
}

MockFirebaseAuthService getAndRegisterFirebaseAuthService() {
  _removeRegistrationIfExists<FirebaseAuthService>();
  final service = MockFirebaseAuthService();
  locator.registerSingleton<FirebaseAuthService>(service);
  return service;
}

MockFirebaseFirestoreService getAndRegisterFirebaseFirestoreService() {
  _removeRegistrationIfExists<FirebaseFirestoreService>();
  final service = MockFirebaseFirestoreService();
  locator.registerSingleton<FirebaseFirestoreService>(service);
  return service;
}

MockPromptService getAndRegisterPromptService() {
  _removeRegistrationIfExists<PromptService>();
  final service = MockPromptService();
  locator.registerSingleton<PromptService>(service);
  return service;
}
// @stacked-mock-create

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
