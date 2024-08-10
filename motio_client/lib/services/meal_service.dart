import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/meal.dart';
import '../util/host_api_data.dart';
import 'base_service.dart';

class MealService extends BaseService {
  static const String _mealsByCategoryUrl = "${HostApiData.baseCoreApiUrl}/meals/category";
  static const String _mealsUrl = "${HostApiData.baseCoreApiUrl}/meals";
  static const String _mealImageUrl = "${HostApiData.baseCoreApiUrl}/images/meals";
  final Dio _dio = Dio();

  Future<List<Meal>> fetchMealsByCategory(String categoryName) async {
    final response = await sendAuthenticatedRequest(
        http.Request(
          'GET',
          Uri.parse('$_mealsByCategoryUrl/$categoryName'),
        )
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final List<dynamic> body = jsonDecode(decoded);
      return body.map((dynamic item) => Meal.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<Meal> getMealById(String mealId) async {
    final response = await sendAuthenticatedRequest(
        http.Request(
          'GET',
          Uri.parse('$_mealsUrl/$mealId'),
        )
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      return Meal.fromJson(jsonDecode(decoded));
    } else {
      throw Exception('Failed to load meal');
    }
  }

  Future<Map<String, dynamic>> updateMeal(String mealId, Map<String, dynamic> mealData) async {
    final response = await sendAuthenticatedRequest(
        http.Request(
          'PUT',
          Uri.parse('$_mealsUrl/$mealId'),
        )
          ..body = jsonEncode(mealData)
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update meal');
    }
  }

  Future<void> deleteMeal(String mealId) async {
    final response = await sendAuthenticatedRequest(
        http.Request(
          'DELETE',
          Uri.parse('$_mealsUrl/$mealId'),
        )
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete meal');
    }
  }

  Future<void> downloadAndSaveImage(String mealId, File file) async {
    try {
      final url = '$_mealImageUrl/$mealId';
      final headers = await getAuthHeaders();
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
        ),
      );
      final imageFile = File(file.path);
      await imageFile.writeAsBytes(response.data!);
    } catch (e) {
      throw Exception('Failed to download image');
    }
  }

  Future<File?> getImageFile(String mealId) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = File('${directory.path}/meal_$mealId.jpg');
    if (await imagePath.exists()) {
      return imagePath;
    } else {
      await downloadAndSaveImage(mealId, imagePath);
      return imagePath;
    }
  }

  Future<Map<String, dynamic>> createMeal(Map<String, dynamic> mealData) async {
    final response = await sendAuthenticatedRequest(
        http.Request(
          'POST',
          Uri.parse('$_mealsUrl'),
        )
          ..body = jsonEncode(mealData)
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create meal');
    }
  }

  Future<void> uploadMealImage(String mealId, File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_mealsUrl/$mealId/image'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await sendAuthenticatedMultipartRequest(request);

    if (response.statusCode != 200) {
      throw Exception('Failed to upload image');
    }
  }
}
