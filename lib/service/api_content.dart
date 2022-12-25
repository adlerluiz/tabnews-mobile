import 'dart:convert';

import 'package:tabnews/constants.dart' as constants;
import 'package:tabnews/service/authenticated_http.dart';

const String baseUrl = constants.apiBaseUrl;

final _httpClient = AuthenticatedHttpClient();

class ApiContent {
  Future<dynamic> get(String ownerUsername, String slug) async {
    final response = await _httpClient
        .get(Uri.parse('$baseUrl/contents/$ownerUsername/$slug'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final Map<String, dynamic> result = jsonDecode(response.body);
      throw result['message'];
    }
  }

  Future<dynamic> getList(
      {int pagina = 1, int porPagina = 30, String estrategia = 'new'}) async {
    final response = await _httpClient.get(Uri.parse(
        '$baseUrl/contents?page=$pagina&per_page=$porPagina&strategy=$estrategia'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  Future<dynamic> getComments(String ownerUsername, String slug) async {
    final response = await _httpClient
        .get(Uri.parse('$baseUrl/contents/$ownerUsername/$slug/children'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  Future<dynamic> postTabcoinTransaction(String ownerUsername, String slug,
      {String transactionType = 'credit'}) async {
    final response = await _httpClient.post(
        Uri.parse('$baseUrl/contents/$ownerUsername/$slug/tabcoins'),
        body: {'transaction_type': transactionType});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final Map<String, dynamic> result = jsonDecode(response.body);
      throw result['message'];
    }
  }

  Future<dynamic> getByUser(String ownerUsername,
      {int pagina = 1, int porPagina = 30, String estrategia = 'new'}) async {
    final response = await _httpClient.get(Uri.parse(
        '$baseUrl/contents/$ownerUsername?page=$pagina&per_page=$porPagina&strategy=$estrategia'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  Future<dynamic> postContent(String title, String body, String sourceUrl,
      {String status = 'published'}) async {
    final payload = {
      'title': title,
      'body': body,
      'status': status,
    };

    if (sourceUrl != '') {
      payload['source_url'] = sourceUrl;
    }

    final response =
        await _httpClient.post(Uri.parse('$baseUrl/contents'), body: payload);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final Map<String, dynamic> result = jsonDecode(response.body);
      throw result['message'];
    }
  }

  Future<dynamic> patchContent(String ownerUsername, String slug, String title,
      String body, String sourceUrl,
      {String status = 'published'}) async {
    final payload = {
      'title': title,
      'body': body,
      'status': status,
    };

    if (sourceUrl != '') {
      payload['source_url'] = sourceUrl;
    }

    final response = await _httpClient.patch(
        Uri.parse('$baseUrl/contents/$ownerUsername/$slug'),
        body: payload);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final Map<String, dynamic> result = jsonDecode(response.body);
      throw result['message'];
    }
  }

  Future<dynamic> deleteContent(String ownerUsername, String slug,
      {String status = 'deleted'}) async {
    final payload = {
      'status': status,
    };

    final response = await _httpClient.patch(
        Uri.parse('$baseUrl/contents/$ownerUsername/$slug'),
        body: payload);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final Map<String, dynamic> result = jsonDecode(response.body);
      throw result['message'];
    }
  }

  Future<dynamic> postComment(String body, String parentId,
      {String status = 'published'}) async {
    final response =
        await _httpClient.post(Uri.parse('$baseUrl/contents'), body: {
      'body': body,
      'parent_id': parentId,
      'status': status,
    });

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final Map<String, dynamic> result = jsonDecode(response.body);
      throw result['message'];
    }
  }

  Future<dynamic> patchComment(
      String ownerUsername, String slug, String body, String parentId,
      {String status = 'published'}) async {
    final response = await _httpClient
        .patch(Uri.parse('$baseUrl/contents/$ownerUsername/$slug'), body: {
      'body': body,
      'parent_id': parentId,
      'status': status,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final Map<String, dynamic> result = jsonDecode(response.body);
      throw result['message'];
    }
  }
}
