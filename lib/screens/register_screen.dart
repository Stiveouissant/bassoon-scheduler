import 'package:bassoon_scheduler_app/data/shared_prefs.dart';
import 'package:bassoon_scheduler_app/main.dart';
import 'package:bassoon_scheduler_app/shared/translations.dart';
import 'package:bassoon_scheduler_app/shared/utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final displayNameController = TextEditingController();
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
    displayNameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(settingColor),
        title: Text(translations["Registration"]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    labelText: translations["Email"]
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                  email != null && !EmailValidator.validate(email)
                    ? translations["ValidEmail"]
                      : null
                ,
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: displayNameController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    labelText: translations["DisplayName"]
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                !RegExp(r"^[a-zA-Z0-9\sżźćńółęąśŻŹĆĄŚĘŁÓŃ]+$").hasMatch(value!)
                    ? translations["NoSpecialChars"]
                    : null
                ,
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    labelText: translations["Password"]
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                value != null && value.length < 6
                    ? translations["PassReqs"]
                    : null
                ,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    primary: Color(settingColor)
                ),
                icon: const FaIcon(
                    FontAwesomeIcons.userPlus, color: Colors.white),
                label: Text(translations["Register"], style: const TextStyle(fontSize: 24)),
                onPressed: signUp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future signUp() async{
    final isValid = formKey.currentState!.validate();
    if(!isValid) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(),)
    );

    try {
      var credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
      );
      await credential.user!.updateDisplayName(displayNameController.text.trim());
    } on FirebaseAuthException catch (e) {
      print(e);
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
    const String field = "register";
    Translations translator = Translations(settingLanguage);
    translations = await translator.readTranslations(field);
  }
}
