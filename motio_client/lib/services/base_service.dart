import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/jwt_response.dart';
import '../util/host_api_data.dart';

abstract class BaseService {
  static const String _authUrl = HostApiData.baseAuthApiUrl;

  Future<void> saveTokens(JwtResponse jwtResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', jwtResponse.accessToken);
    await prefs.setString('refreshToken', jwtResponse.refreshToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  Future<JwtResponse?> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse('$_authUrl/refresh-token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'refreshToken': refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      final jwtResponse = JwtResponse.fromJson(jsonDecode(response.body));
      await saveTokens(jwtResponse);
      return jwtResponse;
    } else {
      return null;
    }
  }

  Future<http.Response> sendAuthenticatedRequest(http.Request request, {bool retry = true}) async {
    final headers = await getAuthHeaders();

    request.headers.addAll(headers);

    final response = await request.send();
    final streamResponse = await http.Response.fromStream(response);

    if (streamResponse.statusCode == 403 && retry) {
      final newTokens = await refreshToken();
      if (newTokens != null) {
        final clonedRequest = http.Request(request.method, request.url)
          ..headers.addAll(headers)
          ..body = request.body;
        clonedRequest.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';
        return await sendAuthenticatedRequest(clonedRequest, retry: false);
      }
    }

    return streamResponse;
  }

  Future<http.StreamedResponse> sendAuthenticatedMultipartRequest(http.MultipartRequest request, {bool retry = true}) async {
    final headers = await getAuthHeaders();
    request.headers.addAll(headers);
    final response = await request.send();
    if (response.statusCode == 403 && retry) {
      final newTokens = await refreshToken();
      if (newTokens != null) {
        final clonedRequest = http.MultipartRequest(request.method, request.url)
          ..headers.addAll(headers)
          ..files.addAll(request.files);
        clonedRequest.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';
        return await sendAuthenticatedMultipartRequest(clonedRequest, retry: false);
      }
    }

    return response;
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final accessToken = await getAccessToken();
    if (accessToken != null) {
      return {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json; charset=UTF-8',
      };
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }
}
