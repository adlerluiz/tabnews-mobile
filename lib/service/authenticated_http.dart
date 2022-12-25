import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tabnews/constants.dart' as constants;
import 'package:tabnews/service/storage.dart';

class AuthenticatedHttpClient extends http.BaseClient {
  StorageService storage = StorageService();
  String _inMemoryToken = '';

  Future<String> get userAccessToken async {
    _inMemoryToken = await _loadTokenFromSharedPreference();
    return _inMemoryToken;
  }

  Future<String> _loadTokenFromSharedPreference() async {
    var accessToken = '';

    await storage.sharedPreferencesGet('token', '').then((data) {
      accessToken = data;
    });

    return accessToken;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await userAccessToken.then((data) {
      if (data.isNotEmpty) {
        request.headers.putIfAbsent('cookie', () => 'session_id=$data');
      }
    });
    return request.send();
  }

  Future<bool> login(String email, String password) async {
    final response =
        await http.post(Uri.parse('${constants.apiBaseUrl}/sessions'), body: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 201) {
      final dynamic body = jsonDecode(response.body);

      final String token = body['token'];
      final String expiresAt = body['expires_at'];
      await storage.sharedPreferencesAddString('token', token);
      await storage.sharedPreferencesAddString('expires_at', expiresAt);

      return true;
    }

    final result = jsonDecode(response.body);
    throw result['message'];
  }

  Future<bool> register(String username, String email, String password) async {
    final response =
        await http.post(Uri.parse('${constants.apiBaseUrl}/users'), body: {
      'username': username,
      'email': email,
      'password': password,
    });

    if (response.statusCode == 201) {
      return true;
    }

    final result = jsonDecode(response.body);
    throw result['message'];
  }

  Future<bool> isLogged() async {
    final now = DateTime.now();
    var expiresAt = await storage.sharedPreferencesGet('expires_at', '$now');
    expiresAt = DateTime.parse(expiresAt);

    return now.compareTo(expiresAt) == -1;
  }

  void logout() {
    storage.sharedPreferencesRemove('token');
    storage.sharedPreferencesRemove('expires_at');
    storage.sharedPreferencesRemove('user_id');
    storage.sharedPreferencesRemove('user_username');
    _inMemoryToken = '';
  }
}
