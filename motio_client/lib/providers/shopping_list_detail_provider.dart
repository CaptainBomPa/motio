import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../models/user.dart';
import '../services/shopping_service.dart';
import 'user_provider.dart';

final shoppingListDetailProvider = StateNotifierProvider.family<ShoppingListDetailNotifier, ShoppingList, int>((ref, id) {
  final shoppingService = ShoppingService();
  return ShoppingListDetailNotifier(shoppingService, id);
});

class ShoppingListDetailNotifier extends StateNotifier<ShoppingList> {
  final ShoppingService _shoppingService;
  final int _id;

  ShoppingListDetailNotifier(this._shoppingService, this._id) : super(ShoppingList(id: _id,
      listName: '',
      items: [],
      createdByUser: User(id: 0,
          username: '',
          firstName: '',
          lastName: '',
          email: ''),
      accessibleUsers: [])) {
    _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    final shoppingList = await _shoppingService.getShoppingListById(_id);
    state = shoppingList;
  }

  void addItem(ShoppingItem item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  void updateItem(ShoppingItem item) {
    state = state.copyWith(
      items: state.items.map((i) => i.id == item.id ? item : i).toList(),
    );
  }

  void removeItem(int itemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != itemId).toList(),
    );
  }

  void toggleItemChecked(int itemId) {
    final items = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(checked: !item.checked);
      }
      return item;
    }).toList();

    state = state.copyWith(items: items);
  }

  void reorderItems(int oldIndex, int newIndex) {
    final items = [...state.items];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    state = state.copyWith(items: items);
  }

  Future<void> saveShoppingList() async {
    await _shoppingService.updateShoppingList(state.id, state.toJson());
  }
}
