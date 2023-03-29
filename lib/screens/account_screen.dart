import 'package:bassoon_scheduler_app/data/shared_prefs.dart';
import 'package:bassoon_scheduler_app/providers/google_sign_in.dart';
import 'package:bassoon_scheduler_app/screens/login_screen.dart';
import 'package:bassoon_scheduler_app/shared/nav_menu.dart';
import 'package:bassoon_scheduler_app/shared/translations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
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
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }else if (snapshot.hasError){
          return Center(child: Text(translations["Somthingwong"]));
        } else if (snapshot.hasData){
          return LoggedInWidget(settingColor: settingColor,
                                settingFontSize: settingFontSize,
                                translations: translations);
        } else {
          return LoggedOutWidget(settingColor: settingColor,
                                  settingFontSize: settingFontSize,
                                  translations: translations);
        }
      }
    );
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

  Future getTranslations() async{
    const String field = "account";
    Translations translator = Translations(settingLanguage);
    translations = await translator.readTranslations(field);
  }
}

class LoggedOutWidget extends StatelessWidget {
  const LoggedOutWidget({
    Key? key,
    required this.settingColor,
    required this.settingFontSize,
    required this.translations
  }) : super(key: key);

  final int settingColor;
  final double settingFontSize;
  final Map<String, dynamic> translations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(settingColor),
        title: Text(translations["Account"]),
      ),
      drawer: const NavMenu(),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF606060),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/bassoon icon.png'),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  translations["AccountScreen"],
                  style: TextStyle(
                      fontSize: settingFontSize + 4,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  translations["LogInToContinue"],
                  style: TextStyle(fontSize: settingFontSize, color: Colors.white),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue,
                      onPrimary: Colors.white,
                      minimumSize: const Size(double.infinity, 50)
                  ),
                  icon: const FaIcon(FontAwesomeIcons.envelope, color: Colors.white),
                  onPressed: (){
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  label: Text(translations["LogInWithEmail"])),
              const Spacer(),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.black,
                      minimumSize: const Size(double.infinity, 50)
                  ),
                  icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red,),
                  onPressed: (){
                    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                    provider.googleLogin();
                  },
                  label: Text(translations["LogInWithGoogle"])),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}


class LoggedInWidget extends StatelessWidget {
  LoggedInWidget({
    Key? key,
    required this.settingColor,
    required this.settingFontSize,
    required this.translations
  }) : super(key: key);

  final int settingColor;
  final double settingFontSize;
  final Map<String, dynamic> translations;

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(settingColor),
        title: Text(translations["Account"]),
      ),
      drawer: const NavMenu(),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF606060),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/bassoon icon.png'),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: Text(
                  translations["YourAccount"],
                  style: TextStyle(
                      fontSize: settingFontSize + 4,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: Text(
                  translations["Info"],
                  style: TextStyle(fontSize: settingFontSize, color: Colors.white),
                ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  text: translations["Email"],
                  style: TextStyle(fontSize: settingFontSize, color: Colors.white),
                  children: [
                    TextSpan(text: user!.email!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  text: translations["DisplayName"],
                  style: TextStyle(fontSize: settingFontSize, color: Colors.white),
                  children: [
                    TextSpan(text: user!.displayName!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.black,
                      minimumSize: const Size(double.infinity, 50)
                  ),
                  icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket, color: Colors.red,),
                  onPressed: (){
                    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                    provider.googleLogout();
                  },
                  label: Text(translations["Logout"])),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
