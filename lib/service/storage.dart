import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Future<bool> sharedPreferencesAddString(key, value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  Future<bool> sharedPreferencesAddBoolean(key, value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  dynamic sharedPreferencesGet(key, defaultValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return prefs.get(key);
    }
    return defaultValue;
  }

  Future<String> sharedPreferencesGetString(key, defaultValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return prefs.getString(key) ?? defaultValue;
    }
    return defaultValue;
  }

  Future<bool> sharedPreferencesRemove(key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  List jsonToList(jsonData) {
    final listDecoded = jsonDecode(jsonData) as List;

    return listDecoded;
  }

  String listToJson(list) => jsonEncode(list);
}
