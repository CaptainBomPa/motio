import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motio_client/util/host_api_data.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/todo_item.dart';
import '../models/todo_list.dart';
import '../models/user.dart';
import '../providers/todo_list_detail_provider.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';
import '../widgets/todo_item_tile.dart';

class TodoListDetailScreen extends ConsumerStatefulWidget {
  final TodoList todoList;

  const TodoListDetailScreen({super.key, required this.todoList});

  @override
  _TodoListDetailScreenState createState() => _TodoListDetailScreenState();
}

class _TodoListDetailScreenState extends ConsumerState<TodoListDetailScreen> {
  bool _isEditing = false;
  bool _hasChanges = false;
  late TodoListDetailNotifier _notifier;
  late TodoList _originalTodoList;
  final TextEditingController _newItemController = TextEditingController();
  final UserService _userService = UserService();
  late StompClient _stompClient;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(todoListDetailProvider(widget.todoList.id).notifier);
    _originalTodoList = widget.todoList.copyWith(
      items: List.from(widget.todoList.items),
    );
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    _stompClient = StompClient(
      config: StompConfig(
        url: "${HostApiData.baseCoreApiWsUrl}/ws/websocket",
        onConnect: _onStompConnect,
        onWebSocketError: (dynamic error) => print(error.toString()),
      ),
    );
    _stompClient.activate();
  }

  void _onStompConnect(StompFrame frame) {
    _stompClient.subscribe(
      destination: '/topic/todo/listUpdates',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final updatedTodoList = TodoList.fromJson(jsonDecode(frame.body!));
          if (updatedTodoList.id == widget.todoList.id) {
            setState(() {
              _notifier.state = updatedTodoList.copyWith(
                items: [
                  ...updatedTodoList.items,
                  ..._notifier.state.items.where((item) => item.id == null),
                ],
              );
            });
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _newItemController.dispose();
    _stompClient.deactivate();
    super.dispose();
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
        await _notifier.saveTodoList();
      } else {
        _notifier.state = _originalTodoList.copyWith(
          items: List.from(_originalTodoList.items),
        );
      }
    }
    return true;
  }

  void _addNewItem() {
    final newItemDescription = _newItemController.text.trim();
    if (newItemDescription.isNotEmpty) {
      final newItem = TodoItem(id: DateTime
          .now()
          .millisecondsSinceEpoch, checked: false, description: newItemDescription);
      _notifier.addItem(newItem);
      _newItemController.clear();
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _shareTodoList() async {
    final allUsers = await _userService.getAllUsers();
    final currentUser = ref.read(userProvider);
    final usersToShow = allUsers.where((user) => user.id != currentUser!.id).toList();
    final theme = Theme.of(context);
    Set<User> accessibleUsers = Set.from(widget.todoList.accessibleUsers);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Udostępnij listę TODO'),
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
                  _notifier.state = widget.todoList.copyWith(
                    accessibleUsers: List.from(accessibleUsers),
                  );
                  await _notifier.saveTodoList();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lista TODO została udostępniona.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Błąd podczas udostępniania listy TODO: $e')),
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

  Future<void> _deleteItem(int itemId) async {
    _notifier.removeItem(itemId);
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todoListState = ref.watch(todoListDetailProvider(widget.todoList.id));
    final currentUser = ref.watch(userProvider);
    final items = [...todoListState.items]..sort((a, b) => a.checked == b.checked ? 0 : (a.checked ? 1 : -1));

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(todoListState.listName),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                await _notifier.saveTodoList();
                setState(() {
                  _hasChanges = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Zmiany zostały zapisane.')),
                );
              },
            ),
            if (currentUser != null && todoListState.createdByUser.id == currentUser.id)
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareTodoList,
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
                    TodoItemTile(
                      key: Key(item.id.toString()),
                      item: item,
                      onItemCheckedToggle: () => _onItemCheckedToggle(item.id),
                      onItemDelete: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Usuń element'),
                              content: const Text('Czy na pewno chcesz usunąć ten element?'),
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

                        if (shouldDelete == true) {
                          await _deleteItem(item.id);
                        }
                      },
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
                      decoration: InputDecoration(
                        labelText: 'Dodaj nowy element',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
                        ),
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
}
