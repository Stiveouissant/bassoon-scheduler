import 'package:bassoon_scheduler_app/providers/google_sign_in.dart';
import 'package:bassoon_scheduler_app/providers/connectivity.dart';
import 'package:bassoon_scheduler_app/screens/main_screen.dart';
import 'package:bassoon_scheduler_app/shared/utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BassoonSchedulerApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class BassoonSchedulerApp extends StatelessWidget {
  const BassoonSchedulerApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GoogleSignInProvider>(create: (context) => GoogleSignInProvider()),
        ChangeNotifierProvider<ConnectivityProvider>(create: (context) => ConnectivityProvider())
      ],
      child: MaterialApp(
        scaffoldMessengerKey: Utils.messengerKey,
        navigatorKey: navigatorKey,
        title: 'Bassoon Scheduler App',
        home: StreamBuilder(
          stream: Connectivity().onConnectivityChanged,
          builder: (context, connectionStatus) {
            if(connectionStatus.data != ConnectivityResult.none)
              {
                return const MainScreen();
              }
            return const Text("nie ma neta");
          }
        ),
      ),
    );
  }
}