import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SPSettings {
  final String fontSizeKey = 'font_size';
  final String colorKey = 'color';
  final String languageKey = 'language';

  static late SharedPreferences _sp;

  static SPSettings? _instance;

  SPSettings._internal();

  factory SPSettings() {
    _instance ??= SPSettings._internal();
    return _instance as SPSettings;
  }

  Future init() async {
    _sp = await SharedPreferences.getInstance();
  }

  Future setLanguage(String language){
    return _sp.setString(languageKey, language);
  }

  String getLanguage() {
    String? language = _sp.getString(languageKey);
    language ??= "PL";
    return language;
  }

  Future setColor(int color) {
    return _sp.setInt(colorKey, color);
  }

  int getColor() {
    int? color = _sp.getInt(colorKey);
    color ??= 0xff1976d2;
    return color;
  }

  Future setFontSize(double size) {
    return _sp.setDouble(fontSizeKey, size);
  }

  double getFontSize() {
    double? fontSize = _sp.getDouble(fontSizeKey);
    fontSize ??= 14;
    return fontSize;
  }
}
