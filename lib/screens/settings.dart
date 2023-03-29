import 'package:bassoon_scheduler_app/shared/translations.dart';
import 'package:flutter/material.dart';
import 'package:bassoon_scheduler_app/data/shared_prefs.dart';
import 'package:bassoon_scheduler_app/shared/nav_menu.dart';
import '../models/font_size.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int settingColor = 0xff1976d2;
  double fontSize = 16;
  String settingLanguage = "PL";
  late Map<String, dynamic> translations;
  List<int> colors = [
    0xFF1976D2,
    0xFFEA0A8E,
    0xFF1EBA47,
    0xFFF57C00,
    0xFF795548,
  ];
  SPSettings settings = SPSettings();

  final List<FontSize> fontSizes = [
    FontSize('S', 12),
    FontSize('M', 16),
    FontSize('L', 20),
    FontSize('XL', 24),
  ];

  @override
  void initState() {
    settings.init().then((value) {
      setState(() {
        settingColor = settings.getColor();
        fontSize = settings.getFontSize();
        settingLanguage = settings.getLanguage();
      });
      getTranslations();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations["Settings"]),
        backgroundColor: Color(settingColor),
      ),
      drawer: const NavMenu(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            translations["ChooseLang"],
            style: TextStyle(fontSize: fontSize, color: Color(settingColor)),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            GestureDetector(
              onTap: () => setLanguage("ENG"),
              child: Image.asset('assets/englishflag.png'),
            ),
            GestureDetector(
              onTap: () => setLanguage("PL"),
              child: Image.asset('assets/polishflag.png'),
            ),
          ]),
          Text(
            translations["ChooseMainTheme"],
            style: TextStyle(fontSize: fontSize, color: Color(settingColor)),
          ),
          Text(
            translations["ChooseFont"],
            style: TextStyle(fontSize: fontSize, color: Color(settingColor)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => changeSize(fontSizes[0].size.toString()),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueGrey,
                  child: Text(fontSizes[0].name, style: TextStyle(fontSize: fontSizes[0].size),),
                ),
              ),
              GestureDetector(
                onTap: () => changeSize(fontSizes[1].size.toString()),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue,
                  child: Text(fontSizes[1].name, style: TextStyle(fontSize: fontSizes[1].size),),
                ),
              ),
              GestureDetector(
                onTap: () => changeSize(fontSizes[2].size.toString()),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.lightBlue,
                  child: Text(fontSizes[2].name, style: TextStyle(fontSize: fontSizes[2].size),),
                ),
              ),
              GestureDetector(
                onTap: () => changeSize(fontSizes[3].size.toString()),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.lightBlueAccent,
                  child: Text(fontSizes[3].name, style: TextStyle(fontSize: fontSizes[3].size),),
                ),
              ),
            ],
          ),
          Text(translations["ChooseColor"],
              style: TextStyle(fontSize: fontSize, color: Color(settingColor))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => setColor(colors[0]),
                child: ColorSquare(colors[0]),
              ),
              GestureDetector(
                onTap: () => setColor(colors[1]),
                child: ColorSquare(colors[1]),
              ),
              GestureDetector(
                onTap: () => setColor(colors[2]),
                child: ColorSquare(colors[2]),
              ),
              GestureDetector(
                onTap: () => setColor(colors[3]),
                child: ColorSquare(colors[3]),
              ),
              GestureDetector(
                onTap: () => setColor(colors[4]),
                child: ColorSquare(colors[4]),
              ),
            ],
          )
        ],
      ),
    );
  }

  void setLanguage(String language){
    if(settingLanguage == language){
      return;
    }
    setState(() {
      settingLanguage = language;
      settings.setLanguage(language);
    });
    Navigator.of(context).pop();
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SettingsScreen())
    );
  }

  void setColor(int color) {
    setState(() {
      settingColor = color;
      settings.setColor(color);
    });
  }

  void changeSize(String? newSize) {
    settings.setFontSize(double.parse(newSize ?? '14'));
    setState(() {
      fontSize = double.parse(newSize ?? '14');
    });
  }

  Future getTranslations() async{
    const String field = "settings";
    Translations translator = Translations(settingLanguage);
    translations = await translator.readTranslations(field);
  }
}

class ColorSquare extends StatelessWidget {
  const ColorSquare(this.colorCode);

  final int colorCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        color: Color(colorCode),
      ),
    );
  }
}
