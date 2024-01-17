import 'package:virtuchat/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:virtuchat/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:virtuchat/ui/views/home/home_view.dart';
import 'package:virtuchat/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:virtuchat/ui/views/login/login_view.dart';
import 'package:virtuchat/ui/views/geminichat/geminichat_view.dart';
import 'package:virtuchat/services/gemini_service.dart';
import 'package:virtuchat/services/firebase_auth_service.dart';
import 'package:virtuchat/services/firebase_firestore_service.dart';
import 'package:virtuchat/services/prompt_service.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: GeminichatView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: GeminiService),
    LazySingleton(classType: FirebaseAuthService),
    LazySingleton(classType: FirebaseFirestoreService),
    LazySingleton(classType: PromptService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
