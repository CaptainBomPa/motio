import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:lottie/lottie.dart';

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
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.red,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Lottie.asset(
          'assets/animations/delete_animation.json',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: theme.primaryColor, width: 4),
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
                      'Potwierdź usunięcie',
                      style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Czy na pewno chcesz usunąć tę listę TODO?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Nie',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: theme.textTheme.headlineLarge!.color,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            'Tak',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: theme.textTheme.headlineLarge!.color,
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
      },
      onDismissed: (direction) async {
        await _deleteTodoList(context, ref);
      },
      child: Padding(
        padding: const EdgeInsets.all(3.0),
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
                Hero(
                  tag: 'todo-${todoList.id}',
                  child: Container(
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
                      border: Border.all(color: theme.colorScheme.primary, width: 3.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple[300]!,
                          blurRadius: 4,
                          offset: const Offset(6, 8),
                        ),
                      ],
                    ),
                    height: 126,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}