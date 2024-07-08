import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../util/host_api_data.dart';
import 'base_service.dart';

class UserService extends BaseService {
  static const String _userUrl = "${HostApiData.baseCoreApiUrl}/users";

  Future<User?> getUserInfo({bool retry = true}) async {
    final response = await sendAuthenticatedRequest(
        http.Request(
          'GET',
          Uri.parse('$_userUrl/me'),
        )
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      return null;
    }
  }

  Future<List<User>> getAllUsers() async {
    final response = await sendAuthenticatedRequest(
        http.Request(
          'GET',
          Uri.parse('$_userUrl'),
        )
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => User.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}
