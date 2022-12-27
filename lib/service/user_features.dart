import 'dart:convert';

import 'package:tabnews/service/storage.dart';

class UserFeaturesService {
  StorageService storage = StorageService();

  dynamic getFeatureList() async =>
      await storage.sharedPreferencesGet('user_features', '');

  Future<bool> hasFeature(String feature) async {
    final String data = await storage.sharedPreferencesGet('user_features', '');
    final List<dynamic> featureList = jsonDecode(data);

    return featureList.contains(feature);
  }
}
