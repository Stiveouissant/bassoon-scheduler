import 'package:bassoon_scheduler_app/data/shared_prefs.dart';
import 'package:bassoon_scheduler_app/main.dart';
import 'package:bassoon_scheduler_app/screens/register_screen.dart';
import 'package:bassoon_scheduler_app/screens/reset_password_screen.dart';
import 'package:bassoon_scheduler_app/shared/translations.dart';
import 'package:bassoon_scheduler_app/shared/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
  void dispose(){
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(settingColor),
        title: Text(translations["Login"]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: translations["Email"]
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                  labelText: translations["Password"]
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                primary: Color(settingColor)
              ),
              icon: const FaIcon(FontAwesomeIcons.rightToBracket, color: Colors.white),
              label: Text(translations["LogginIn"], style: const TextStyle(fontSize: 24)),
              onPressed: signIn,
            ),
            const SizedBox(height: 24),
            RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                  text: translations["NoAccount"],
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()..onTap = (){
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const RegisterScreen())
                        );
                      },
                      text: translations["Register"],
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.primary
                      )
                    )
                  ]
                )
            ),
            const SizedBox(height: 20),
            RichText(
                text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                    text: translations["Forgor"],
                    children: [
                      TextSpan(
                          recognizer: TapGestureRecognizer()..onTap = (){
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const ResetPasswordScreen())
                            );
                          },
                          text: translations["Reset"],
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Theme.of(context).colorScheme.primary
                          )
                      )
                    ]
                )
            ),
          ],
        ),
      ),
    );
  }
  
  Future signIn() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(),)
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
      );
    } on FirebaseAuthException catch (e) {

      Utils.showSnackBar(e.message);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
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
    const String field = "login";
    Translations translator = Translations(settingLanguage);
    translations = await translator.readTranslations(field);
  }
}
