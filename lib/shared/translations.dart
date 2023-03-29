import 'dart:convert';

import 'package:flutter/services.dart';

class Translations {
  Translations(this.language);

  String language;

  Future<Map<String, dynamic>> readTranslations(String field) async {
    final String file = "assets/$language.json";
    final String response = await rootBundle.loadString(file);
    final data = await json.decode(response);
    return data[field];
  }

}