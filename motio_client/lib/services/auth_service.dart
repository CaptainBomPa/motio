import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/jwt_response.dart';
import '../util/host_api_data.dart';
import 'base_service.dart';

class AuthService extends BaseService {
  static const String _authUrl = HostApiData.baseAuthApiUrl;

  Future<JwtResponse?> loginUser(String username, String password) async {
    final response = await sendAuthenticatedRequest(
      http.Request('POST', Uri.parse('$_authUrl/login'))
        ..body = jsonEncode(<String, String>{
          'username': username,
          'password': password,
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

  Future<bool> registerUser(String username, String firstName, String lastName, String email, String password) async {
    final response = await sendAuthenticatedRequest(
      http.Request('POST', Uri.parse('$_authUrl/register'))
        ..body = jsonEncode(<String, String>{
          'username': username,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        }),
    );
    return response.statusCode == 200;
  }

  Future<JwtResponse?> checkAndRefreshTokens() async {
    final token = await getRefreshToken();
    if (token != null) {
      return await refreshToken();
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }
}
