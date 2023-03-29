import 'package:bassoon_scheduler_app/screens/account_screen.dart';
import 'package:bassoon_scheduler_app/shared/nav_menu.dart';
import 'package:bassoon_scheduler_app/shared/translations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bassoon_scheduler_app/data/shared_prefs.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int settingColor = 0xff1976d2;
  double settingFontSize = 16;
  String settingLanguage = "PL";
  SPSettings settings = SPSettings();
  late Map<String, dynamic> translations;

  @override
  void initState() {
    getSettingsAndTranslations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(translations["Somthingwong"]));
          } else if (snapshot.hasData) {
            final user = FirebaseAuth.instance.currentUser;
            final displayName = user?.displayName ?? "";
            return Scaffold(
                appBar: AppBar(
                    backgroundColor: Color(settingColor),
                    title: Text(translations["MainScreen"])),
                drawer: const NavMenu(),
                body: Container(
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/mainscreen.jpg'),
                            fit: BoxFit.cover)),
                    child: Center(
                        child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                                color: Colors.white70,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Text(
                              "${translations["Hi"]} $displayName, \n${translations["Practiced"]}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: settingFontSize,
                                  shadows: const [
                                    Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 2.0,
                                        color: Colors.grey)
                                  ]),
                            ))))
                );
          } else {
            return AccountScreen();
          }
        });
  }

  Future getSettingsAndTranslations() async {
    settings = SPSettings();
    settings.init().then((value) async {
      setState(() {
        settingColor = settings.getColor();
        settingFontSize = settings.getFontSize();
        settingLanguage = settings.getLanguage();
      });
      getTranslations();
    });
  }

  Future getTranslations() async {
    const String field = "mainscreen";
    Translations translator = Translations(settingLanguage);
    translations = await translator.readTranslations(field);
  }
}
