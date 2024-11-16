import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../models/todo_item.dart';
import '../models/todo_list.dart';
import '../models/user.dart';
import '../providers/todo_list_detail_provider.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';
import '../util/host_api_data.dart';
import '../widgets/todo_item_tile.dart';

class TodoListDetailScreen extends ConsumerStatefulWidget {
  final TodoList todoList;

  const TodoListDetailScreen({super.key, required this.todoList});

  @override
  ConsumerState<TodoListDetailScreen> createState() => _TodoListDetailScreenState();
}

class _TodoListDetailScreenState extends ConsumerState<TodoListDetailScreen> {
  final TextEditingController _newItemController = TextEditingController();
  final UserService _userService = UserService();
  late TodoListDetailNotifier _notifier;
  late TodoList _originalTodoList;
  late StompClient _stompClient;
  bool _hasChanges = false;

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
      final newItem = TodoItem(id: DateTime.now().millisecondsSinceEpoch, checked: false, description: newItemDescription);
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
        return Dialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme
                .of(context)
                .primaryColor, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const Svg('assets/main/dialog_background.svg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.6), BlendMode.lighten),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Udostępnij listę TODO',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Wprowadzone zmiany zostaną zastosowane po udostępnieniu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme
                        .of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
                const SizedBox(height: 16.0),
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
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .primary,
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
                        activeColor: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                        checkColor: Theme
                            .of(context)
                            .colorScheme
                            .onPrimary,
                        selectedTileColor: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                        side: BorderSide(color: Theme
                            .of(context)
                            .colorScheme
                            .primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Anuluj',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                          color: Theme
                              .of(context)
                              .textTheme
                              .headlineLarge!
                              .color,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          final items = _notifier.state.items;
                          _notifier.state = widget.todoList.copyWith(
                            accessibleUsers: List.from(accessibleUsers),
                            items: items,
                          );
                          await _notifier.saveTodoList();
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Lista TODO została udostępniona.')));
                          _hasChanges = false;
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Błąd podczas udostępniania listy TODO')));
                        }
                      },
                      child: Text(
                        'Zapisz',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                          color: Theme
                              .of(context)
                              .textTheme
                              .headlineLarge!
                              .color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

    final imageIndex = (widget.todoList.id % 10) + 1;
    final imagePath = 'assets/todo/todo-$imageIndex.png';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const Svg('assets/main/dialog_background.svg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
            ),
          ),
          child: Column(
            children: [
              Hero(
                tag: 'todo-${widget.todoList.id}',
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.66),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 28.0, bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                        color: Colors.white,
                        iconSize: 30,
                      ),
                      Expanded(
                        child: Text(
                          todoListState.listName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () async {
                          await _notifier.saveTodoList();
                          setState(() {
                            _hasChanges = false;
                          });
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zmiany zostały zapisane.')));
                        },
                        color: Colors.white,
                        iconSize: 30,
                      ),
                      if (currentUser != null && todoListState.createdByUser.id == currentUser.id)
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: _shareTodoList,
                          color: Colors.white,
                          iconSize: 30,
                        ),
                    ],
                  ),
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
                          fillColor: Colors.white.withOpacity(0.6),
                          filled: true,
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
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addNewItem,
                        color: Colors.white,
                        iconSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView(
                  onReorder: _onReorder,
                  children: [
                    for (var item in items)
                      Container(
                        key: Key(item.id.toString()),
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          border: Border(
                            top: BorderSide(color: theme.colorScheme.primary, width: 1.0),
                            bottom: BorderSide(color: theme.colorScheme.primary, width: 1.0),
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TodoItemTile(
                          item: item,
                          onItemCheckedToggle: () => _onItemCheckedToggle(item.id),
                          onItemDelete: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Theme
                                        .of(context)
                                        .primaryColor, width: 4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: const Svg('assets/main/dialog_background.svg'),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.6), BlendMode.lighten),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Czy na pewno chcesz usunąć ten element?',
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16.0),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: Text(
                                                'Nie',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                  color: Theme
                                                      .of(context)
                                                      .textTheme
                                                      .headlineLarge!
                                                      .color,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: Text(
                                                'Tak',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                  color: Theme
                                                      .of(context)
                                                      .textTheme
                                                      .headlineLarge!
                                                      .color,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            if (shouldDelete == true) {
                              await _deleteItem(item.id);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
