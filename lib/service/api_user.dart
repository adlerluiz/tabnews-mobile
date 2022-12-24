import 'dart:convert';

import 'package:tabnews/constants.dart' as constants;
import 'package:tabnews/service/authenticated_http.dart';

const String baseUrl = constants.apiBaseUrl;

final _httpClient = AuthenticatedHttpClient();

class ApiUser {
  Future<dynamic> getMe() async {
    dynamic response;

    response = await _httpClient.get(Uri.parse('$baseUrl/user'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final result = jsonDecode(response.body);
      throw result['message'];
    }
  }

  Future<dynamic> getUser(String ownerUsername) async {
    dynamic response;

    response =
        await _httpClient.get(Uri.parse('$baseUrl/users/$ownerUsername'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }
}
