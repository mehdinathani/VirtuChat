import 'package:firebase_auth/firebase_auth.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:virtuchat/app/app.locator.dart';
import 'package:virtuchat/app/app.router.dart';
import 'package:virtuchat/services/firebase_auth_service.dart';
import 'package:virtuchat/services/firebase_firestore_service.dart';

class LoginViewModel extends BaseViewModel {
  final FirebaseAuthService _firebaseAuthService =
      locator<FirebaseAuthService>();
  final FirebaseFirestoreService _firebaseFirestoreService =
      locator<FirebaseFirestoreService>();
  final NavigationService _navigationservice = locator<NavigationService>();

  loginWithGoogle() {
    _firebaseAuthService.signinWithGoogle();
  }

  guestSignin() {
    _firebaseAuthService.signInAnonymously();
  }

  Future<void> checkUserStatus() async {
    User? user = _firebaseAuthService.auth.currentUser;

    if (user != null) {
      // User is already logged in, navigate to HomeView
      _navigationservice.navigateToHomeView();
    } else {
      // User is not logged in, navigate to LoginView
      _navigationservice.navigateToLoginView();
    }
  }
}
