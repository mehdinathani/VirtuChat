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
          body: SafeArea(
            child: viewModel.isBusy
                ? Center(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Image.asset("assets/image/virtubot.png"),
                      const SizedBox(height: 20),
                      const Text(
                        "Please Wait...",
                        style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff9E9E9E)),
                      ),
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                    ],
                  ))
                : Container(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Add your login UI components here
                          const Text(
                            "Welcome back 👋🏼",
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Please Login with your Google Account to sign in",
                            style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff9E9E9E)),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () async {
                              await viewModel.loginWithGoogle();
                              await viewModel.checkUserStatus();
                            },
                            child: Image.asset(
                                "assets/image/googleloginbutton.png"),
                          ),
                          // ElevatedButton(
                          //   onPressed: () async {
                          //     // Call the signInWithGoogle method from the view model
                          //     await viewModel.loginWithGoogle();
                          //     await viewModel.checkUserStatus();
                          //   },
                          //   child: const Text('Login with Google'),
                          // ),

                          const SizedBox(height: 40),
                          const Row(children: <Widget>[
                            Expanded(child: Divider()),
                            Text("      OR      "),
                            Expanded(child: Divider()),
                          ]),
                          const SizedBox(height: 40),

                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black)),
                            onPressed: () async {
                              // Call the signInAnonymously method from the view model
                              await viewModel.guestSignin();
                              await viewModel.checkUserStatus();
                            },
                            child: const Text(
                              'Guest Login',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
