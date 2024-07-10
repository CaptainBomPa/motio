import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shopping_list.dart';
import '../util/host_api_data.dart';
import 'base_service.dart';

class ShoppingService extends BaseService {
  static const String _shoppingListsUrl = "${HostApiData.baseCoreApiUrl}/shopping-lists";

  Future<List<ShoppingList>> fetchAllShoppingLists() async {
    final response = await sendAuthenticatedRequest(
        http.Request('GET', Uri.parse(_shoppingListsUrl))
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final List<dynamic> body = jsonDecode(decoded);
      return body.map((dynamic item) => ShoppingList.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load shopping lists');
    }
  }

  Future<ShoppingList> getShoppingListById(int id) async {
    final response = await sendAuthenticatedRequest(
        http.Request('GET', Uri.parse('$_shoppingListsUrl/$id'))
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      return ShoppingList.fromJson(jsonDecode(decoded));
    } else {
      throw Exception('Failed to load shopping list');
    }
  }

  Future<ShoppingList> updateShoppingList(int id, Map<String, dynamic> listData) async {
    final response = await sendAuthenticatedRequest(
        http.Request('PUT', Uri.parse('$_shoppingListsUrl/$id'))
          ..body = jsonEncode(listData)
    );

    if (response.statusCode == 200) {
      return ShoppingList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update shopping list');
    }
  }

  Future<void> deleteShoppingList(int id) async {
    final response = await sendAuthenticatedRequest(
        http.Request('DELETE', Uri.parse('$_shoppingListsUrl/$id'))
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete shopping list');
    }
  }
}
