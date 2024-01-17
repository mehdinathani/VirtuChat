import 'package:firebase_auth/firebase_auth.dart';
import 'package:stacked/stacked.dart';
import 'package:virtuchat/app/app.locator.dart';
import 'package:virtuchat/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:virtuchat/services/firebase_auth_service.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final FirebaseAuthService _firebaseAuthService =
      locator<FirebaseAuthService>();

  // Place anything here that needs to happen before we get into the application
  Future runStartupLogic() async {
    await Future.delayed(const Duration(seconds: 3));

    // This is where you can make decisions on where your app should navigate when
    // you have custom startup logic
// Check if the user is already authenticated
    // Check if the user is already authenticated
    User? user = _firebaseAuthService.auth.currentUser;

    if (user != null) {
      // User is already logged in, navigate to HomeView
      _navigationService.replaceWithHomeView();
    } else {
      // User is not logged in, navigate to LoginView
      _navigationService.replaceWithLoginView();
    }
  }
  // _navigationService.replaceWithHomeView();
}
