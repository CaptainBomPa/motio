import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/todo_list.dart';
import '../providers/todo_list_provider.dart';
import '../providers/user_provider.dart';
import '../screens/todo_list_detail_screen.dart';
import '../services/todo_service.dart';

class TodoListTile extends ConsumerWidget {
  final TodoList todoList;
  final TodoService todoService = TodoService();

  TodoListTile({super.key, required this.todoList});

  Future<void> _deleteTodoList(BuildContext context, WidgetRef ref) async {
    try {
      await todoService.deleteTodoList(todoList.id);
      ref.invalidate(todoListProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lista TODO została usunięta.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd podczas usuwania listy TODO: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final checkedItemsCount = todoList.items.where((item) => item.checked).length;
    final uncheckedItemsCount = todoList.items.length - checkedItemsCount;
    final currentUser = ref.watch(userProvider);

    final isSharedByAnotherUser = currentUser != null && todoList.createdByUser.id != currentUser.id;

    final imageIndex = (todoList.id % 10) + 1;
    final imagePath = 'assets/todo/todo-$imageIndex.png';

    return Dismissible(
      key: Key(todoList.id.toString()),
      direction: currentUser != null && todoList.createdByUser.id == currentUser.id
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
              content: const Text("Czy na pewno chcesz usunąć tę listę TODO?"),
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
        await _deleteTodoList(context, ref);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TodoListDetailScreen(todoList: todoList),
              ),
            ).then((_) => ref.invalidate(todoListProvider));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        BlendMode.darken,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  height: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Text(
                              todoList.listName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 3
                                  ..color = isDarkMode ? Colors.black : Colors.white,
                              ),
                            ),
                            Text(
                              todoList.listName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              Stack(
                                children: [
                                  Text(
                                    '$checkedItemsCount',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 16,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 3
                                        ..color = isDarkMode ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '$checkedItemsCount',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.cancel, color: Colors.red),
                              Stack(
                                children: [
                                  Text(
                                    '$uncheckedItemsCount',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 16,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 3
                                        ..color = isDarkMode ? Colors.black : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '$uncheckedItemsCount',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isSharedByAnotherUser) ...[
                        const Spacer(),
                        Center(
                          child: Stack(
                            children: [
                              Text(
                                'Udostępnione przez: ${todoList.createdByUser.firstName} ${todoList.createdByUser.lastName}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 1.5
                                    ..color = isDarkMode ? Colors.black : Colors.white,
                                ),
                              ),
                              Text(
                                'Udostępnione przez: ${todoList.createdByUser.firstName} ${todoList.createdByUser.lastName}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
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
