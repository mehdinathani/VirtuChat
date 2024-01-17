import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:virtuchat/app/app.bottomsheets.dart';
import 'package:virtuchat/app/app.dialogs.dart';
import 'package:virtuchat/app/app.locator.dart';
import 'package:virtuchat/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:virtuchat/config.dart';
import 'package:virtuchat/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
    );
  }
}
