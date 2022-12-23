import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tabnews/service/storage.dart';
import 'package:tabnews/constants.dart' as constants;

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
    var response =
        await http.post(Uri.parse('${constants.apiBaseUrl}/sessions'), body: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 201) {
      dynamic body = jsonDecode(response.body);

      String token = body['token'];
      String expiresAt = body['expires_at'];
      storage.sharedPreferencesAddString('token', token);
      storage.sharedPreferencesAddString('expires_at', expiresAt);

      return true;
    }

    var result = jsonDecode(response.body);
    throw result['message'];
  }

  Future<bool> register(String username, String email, String password) async {
    var response =
        await http.post(Uri.parse('${constants.apiBaseUrl}/users'), body: {
      'username': username,
      'email': email,
      'password': password,
    });

    if (response.statusCode == 201) {
      return true;
    }

    var result = jsonDecode(response.body);
    throw result['message'];
  }

  Future<bool> isLogged() async {
    bool isLogged = false;

    var now = DateTime.now();
    var expiresAt = await storage.sharedPreferencesGet('expires_at', '$now');
    expiresAt = DateTime.parse(expiresAt);

    if (now.compareTo(expiresAt) == -1) {
      isLogged = true;
    }

    return isLogged;
  }

  void logout() {
    storage.sharedPreferencesRemove('token');
    storage.sharedPreferencesRemove('expires_at');
    storage.sharedPreferencesRemove('user_id');
    storage.sharedPreferencesRemove('user_username');
    _inMemoryToken = '';
  }
}
