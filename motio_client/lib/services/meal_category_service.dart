import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_category.dart';
import '../util/host_api_data.dart';
import 'base_service.dart';

class MealCategoryService extends BaseService {
  static const String _mealCategoryUrl = "${HostApiData.baseCoreApiUrl}/mealCategories";
  static const String _mealCategoryImageUrl = "${HostApiData.baseCoreApiUrl}/images/mealCategories";
  static const String _categoriesKey = 'mealCategories';
  final Dio _dio = Dio();

  Future<List<MealCategory>> fetchMealCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCategories = prefs.getString(_categoriesKey);

    if (savedCategories != null) {
      final List<dynamic> savedList = jsonDecode(savedCategories);
      final categories = savedList.map((e) => MealCategory.fromJson(e)).toList();

      _fetchAndUpdateCategories();
      return categories;
    } else {
      return await _fetchAndUpdateCategories();
    }
  }

  Future<List<MealCategory>> _fetchAndUpdateCategories() async {
    final response = await sendAuthenticatedRequest(
      http.Request('GET', Uri.parse(_mealCategoryUrl))
        ..headers.addAll({
          'Content-Type': 'application/json; charset=UTF-8',
        }),
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final List<dynamic> body = jsonDecode(decoded);
      final categories = body.map((dynamic item) => MealCategory.fromJson(item)).toList();

      await _saveCategories(categories);
      await _saveImages(categories);

      return categories;
    } else {
      throw Exception('Failed to load meal categories');
    }
  }

  Future<void> _saveCategories(List<MealCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = jsonEncode(categories.map((e) => e.toJson()).toList());
    await prefs.setString(_categoriesKey, categoriesJson);
  }

  Future<void> _saveImages(List<MealCategory> categories) async {
    final directory = await getApplicationDocumentsDirectory();
    for (final category in categories) {
      final imagePath = File('${directory.path}/${category.name}.jpg');
      final imageUrl = "$_mealCategoryImageUrl/${category.name}";

      try {
        if (!await imagePath.exists() || (await imagePath.readAsBytes()).isEmpty) {
          await _downloadAndSaveImage(imageUrl, imagePath);
        }
      } catch (e) {
        print('Failed to download image for category ${category.name}: $e');
      }
    }
  }

  Future<void> _downloadAndSaveImage(String url, File file) async {
    try {
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
      print('Failed to download image from $url: $e');
      throw Exception('Failed to download image');
    }
  }

  Future<File?> getImageFile(String categoryName) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = File('${directory.path}/${categoryName}.jpg');
    if (await imagePath.exists()) {
      return imagePath;
    }
    return null;
  }
}
