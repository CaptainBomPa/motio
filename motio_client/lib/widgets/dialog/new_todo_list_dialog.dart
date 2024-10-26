import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:motio_client/models/user.dart';

import '../../models/todo_list.dart';
import '../../providers/todo_list_provider.dart';
import '../../services/todo_service.dart';

class NewTodoListDialog extends ConsumerStatefulWidget {
  const NewTodoListDialog({super.key});

  @override
  ConsumerState<NewTodoListDialog> createState() => _NewTodoListDialogState();
}

class _NewTodoListDialogState extends ConsumerState<NewTodoListDialog> {
  final TextEditingController _newListController = TextEditingController();
  final TodoService _todoService = TodoService();

  @override
  void dispose() {
    _newListController.dispose();
    super.dispose();
  }

  Future<void> _createTodoList(BuildContext context) async {
    final listName = _newListController.text.trim();
    if (listName.isNotEmpty) {
      final newTodoList = TodoList(
          id: 0,
          listName: listName,
          items: [],
          accessibleUsers: [],
          createdByUser: User(id: 0, username: '', firstName: '', lastName: '', email: ''));
      try {
        await _todoService.createTodoList(newTodoList.toJson());
        ref.invalidate(todoListProvider);
        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lista TODO została utworzona.')));
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Błąd podczas tworzenia listy TODO.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Utwórz nową listę TODO',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _newListController,
              decoration: InputDecoration(
                fillColor: Colors.white.withOpacity(0.7),
                filled: true,
                labelText: 'Nazwa listy',
                border: const OutlineInputBorder(),
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
                  onPressed: () => _createTodoList(context),
                  child: Text(
                    'Utwórz',
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
  }
}
