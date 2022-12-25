import 'dart:convert';

import 'package:tabnews/constants.dart' as constants;
import 'package:tabnews/service/authenticated_http.dart';

const String baseUrl = constants.apiBaseUrl;

final _httpClient = AuthenticatedHttpClient();

class ApiUser {
  Future<dynamic> getMe() async {
    final response = await _httpClient.get(Uri.parse('$baseUrl/user'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final Map<String, dynamic> result = jsonDecode(response.body);
      throw result['message'];
    }
  }

  Future<dynamic> getUser(String ownerUsername) async {
    final response =
        await _httpClient.get(Uri.parse('$baseUrl/users/$ownerUsername'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }
}
