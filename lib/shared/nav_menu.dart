import 'package:bassoon_scheduler_app/data/shared_prefs.dart';
import 'package:bassoon_scheduler_app/screens/account_screen.dart';
import 'package:bassoon_scheduler_app/screens/bassoon_classes_screen.dart';
import 'package:bassoon_scheduler_app/screens/bassoon_lessons_screen.dart';
import 'package:bassoon_scheduler_app/shared/translations.dart';
import 'package:flutter/material.dart';
import 'package:bassoon_scheduler_app/screens/main_screen.dart';
import 'package:bassoon_scheduler_app/screens/settings.dart';

class NavMenu extends StatefulWidget {
  const NavMenu({Key? key}) : super(key: key);

  @override
  State<NavMenu> createState() => _NavMenuState();
}

class _NavMenuState extends State<NavMenu> {
  int settingColor = 0xffffffff;
  double settingFontSize = 16;
  String settingLanguage = "PL";
  SPSettings settings = SPSettings();
  Map<String, dynamic> translations = {};
  @override
  void initState() {
    getSettingsAndTranslations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: buildMenuItems(context)
      )
    );
  }

  List<Widget> buildMenuItems(BuildContext context){
    final List<NavTile> navMenuTiles = [
      NavTile(translations["MainScreen"], Icons.home, 0),
      NavTile(translations["Classes"], Icons.assignment, 1),
      NavTile(translations["Lessons"], Icons.play_lesson, 2),
      NavTile(translations["Settings"], Icons.settings, 3),
      NavTile(translations["Account"], Icons.account_box, 4),
    ];
    List<Widget> menuItems = [];
    menuItems.add(DrawerHeader(
      decoration: BoxDecoration(color: Color(settingColor)),
      child: const Text('Bassoon Scheduler App', style: TextStyle(color: Colors.white, fontSize: 28),)
    ));
    navMenuTiles.forEach((navtile) {
      Widget screen = Container();
      menuItems.add(ListTile(
        title: Row(
          children: [
            Text(
              navtile.title,
              style: TextStyle(fontSize: settingFontSize),
            ),
            const SizedBox(width: 8),
            Icon(navtile.icon),
          ],
        ),
        onTap: () {
          switch(navtile.widgetIndex){
            case 0:
              screen = MainScreen();
              break;
            case 1:
              screen = BassoonClassesScreen();
              break;
            case 2:
              screen = BassoonLessonsScreen();
              break;
            case 3:
              screen = SettingsScreen();
              break;
            case 4:
              screen = AccountScreen();
              break;
          }
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => screen)
          );
        },
      ));
    });
    return menuItems;

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
    const String field = "navigation";
    Translations translator = Translations(settingLanguage);
    translations = await translator.readTranslations(field);
  }
}

class NavTile{
  NavTile(this.title, this.icon, this.widgetIndex);

  String title;
  IconData icon;
  int widgetIndex;
}
