import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_list.dart';
import '../screens/shopping_list_detail_screen.dart';
import '../providers/user_provider.dart';
import '../services/shopping_service.dart';

class ShoppingListTile extends ConsumerWidget {
  final ShoppingList shoppingList;
  final ShoppingService shoppingService = ShoppingService();

  ShoppingListTile({super.key, required this.shoppingList});

  Future<void> _deleteShoppingList(BuildContext context) async {
    try {
      await shoppingService.deleteShoppingList(shoppingList.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lista zakupowa została usunięta.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas usuwania listy zakupowej: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final checkedItemsCount = shoppingList.items
        .where((item) => item.checked)
        .length;
    final uncheckedItemsCount = shoppingList.items.length - checkedItemsCount;
    final currentUser = ref.watch(userProvider);

    final isSharedByAnotherUser = currentUser != null && shoppingList.createdByUser.id != currentUser.id;

    return Dismissible(
      key: Key(shoppingList.id.toString()),
      direction: currentUser != null && shoppingList.createdByUser.id == currentUser.id
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Potwierdź usunięcie"),
              content: const Text("Czy na pewno chcesz usunąć tę listę zakupową?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Nie"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Tak"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        await _deleteShoppingList(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShoppingListDetailScreen(shoppingList: shoppingList),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Stack(
              children: [
                Container(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  height: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          shoppingList.listName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              Text('$checkedItemsCount'),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.cancel, color: Colors.red),
                              Text('$uncheckedItemsCount'),
                            ],
                          ),
                        ],
                      ),
                      if (isSharedByAnotherUser) ...[
                        const Spacer(),
                        Center(
                          child: Text(
                            'Udostępnione przez: ${shoppingList.createdByUser.firstName} ${shoppingList.createdByUser.lastName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
