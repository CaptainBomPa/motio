import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_list.dart';
import '../services/shopping_service.dart';

final shoppingListProvider = FutureProvider<List<ShoppingList>>((ref) async {
  final shoppingService = ShoppingService();
  return await shoppingService.fetchAllShoppingLists();
});
