import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_item.dart';
import '../models/shopping_list.dart';
import '../models/user.dart';
import '../providers/shopping_list_detail_provider.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';

class ShoppingListDetailScreen extends ConsumerStatefulWidget {
  final ShoppingList shoppingList;

  const ShoppingListDetailScreen({super.key, required this.shoppingList});

  @override
  _ShoppingListDetailScreenState createState() => _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends ConsumerState<ShoppingListDetailScreen> {
  bool _isEditing = false;
  bool _hasChanges = false;
  late ShoppingListDetailNotifier _notifier;
  late ShoppingList _originalShoppingList;
  final TextEditingController _newItemController = TextEditingController();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(shoppingListDetailProvider(widget.shoppingList.id).notifier);
    _originalShoppingList = widget.shoppingList.copyWith(
      items: List.from(widget.shoppingList.items),
    );
  }

  void _onItemCheckedToggle(int itemId) {
    _notifier.toggleItemChecked(itemId);
    setState(() {
      _hasChanges = true;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    _notifier.reorderItems(oldIndex, newIndex);
    setState(() {
      _hasChanges = true;
    });
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Zapisz zmiany?'),
            content: const Text('Czy chcesz zapisać wprowadzone zmiany przed wyjściem?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Nie'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Tak'),
              ),
            ],
          );
        },
      );

      if (shouldSave == true) {
        await _notifier.saveShoppingList();
      } else {
        // Przywróć oryginalny stan
        _notifier.state = _originalShoppingList.copyWith(
          items: List.from(_originalShoppingList.items),
        );
      }
    }
    return true;
  }

  void _addNewItem() {
    final newItemDescription = _newItemController.text.trim();
    if (newItemDescription.isNotEmpty) {
      final newItem = ShoppingItem(id: DateTime
          .now()
          .millisecondsSinceEpoch, checked: false, description: newItemDescription);
      _notifier.addItem(newItem);
      _newItemController.clear();
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _shareShoppingList() async {
    final allUsers = await _userService.getAllUsers();
    final currentUser = ref.read(userProvider);
    final usersToShow = allUsers.where((user) => user.id != currentUser!.id).toList();
    final theme = Theme.of(context);
    Set<User> accessibleUsers = Set.from(widget.shoppingList.accessibleUsers);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Udostępnij listę zakupową'),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Wprowadzone zmiany zostaną zastosowane po udostępnieniu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery
                            .of(context)
                            .size
                            .height * 0.5,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: usersToShow.length,
                        itemBuilder: (context, index) {
                          final user = usersToShow[index];
                          return CheckboxListTile(
                            title: Text(
                              '${user.firstName} ${user.lastName}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            value: accessibleUsers.contains(user),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  accessibleUsers.add(user);
                                } else {
                                  accessibleUsers.remove(user);
                                }
                              });
                            },
                            activeColor: theme.colorScheme.primary,
                            checkColor: theme.colorScheme.onPrimary,
                            selectedTileColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Anuluj'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  _notifier.state = widget.shoppingList.copyWith(
                    accessibleUsers: List.from(accessibleUsers),
                  );
                  await _notifier.saveShoppingList();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lista zakupowa została udostępniona.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Błąd podczas udostępniania listy zakupowej: $e')),
                  );
                }
              },
              child: Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shoppingListState = ref.watch(shoppingListDetailProvider(widget.shoppingList.id));
    final currentUser = ref.watch(userProvider);
    final items = [...shoppingListState.items]..sort((a, b) => a.checked == b.checked ? 0 : (a.checked ? 1 : -1));

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(shoppingListState.listName),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                await _notifier.saveShoppingList();
                setState(() {
                  _hasChanges = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Zmiany zostały zapisane.')),
                );
              },
            ),
            if (currentUser != null && shoppingListState.createdByUser?.id == currentUser.id)
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareShoppingList,
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ReorderableListView(
                onReorder: _onReorder,
                children: [
                  for (var item in items)
                    ListTile(
                      key: Key(item.id.toString()),
                      title: Text(
                        item.description,
                        style: TextStyle(
                          decoration: item.checked ? TextDecoration.lineThrough : null,
                          color: item.checked
                              ? theme.textTheme.bodyMedium!.color!.withOpacity(0.5)
                              : theme.textTheme.bodyMedium!.color,
                        ),
                      ),
                      trailing: Checkbox(
                        value: item.checked,
                        onChanged: (_) => _onItemCheckedToggle(item.id),
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newItemController,
                      decoration: const InputDecoration(
                        labelText: 'Dodaj nowy element',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addNewItem,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }
}
