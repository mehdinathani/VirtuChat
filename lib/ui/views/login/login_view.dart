import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'login_viewmodel.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Container(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Add your login UI components here

                  ElevatedButton(
                    onPressed: () async {
                      // Call the signInWithGoogle method from the view model
                      await viewModel.loginWithGoogle();
                      await viewModel.checkUserStatus();
                    },
                    child: const Text('Login with Google'),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      // Call the signInAnonymously method from the view model
                      await viewModel.guestSignin();
                      await viewModel.checkUserStatus();
                    },
                    child: const Text('Login Anonymously'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
