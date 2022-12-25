import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Future<bool> sharedPreferencesAddString(String key, dynamic value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  Future<bool> sharedPreferencesAddBoolean(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  dynamic sharedPreferencesGet(String key, dynamic defaultValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return prefs.get(key);
    }
    return defaultValue;
  }

  Future<String> sharedPreferencesGetString(
      String key, String defaultValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return prefs.getString(key) ?? defaultValue;
    }
    return defaultValue;
  }

  Future<bool> sharedPreferencesRemove(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  List<dynamic> jsonToList(dynamic jsonData) {
    final listDecoded = jsonDecode(jsonData) as List;

    return listDecoded;
  }

  String listToJson(List<dynamic> list) => jsonEncode(list);
}
