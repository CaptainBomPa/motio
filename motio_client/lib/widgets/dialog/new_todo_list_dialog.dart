import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return SizedBox(
      width: double.infinity,
      child: AlertDialog(
        title: const Text('Utwórz nową listę TODO'),
        content: TextField(
          controller: _newListController,
          decoration: const InputDecoration(
            labelText: 'Nazwa listy',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => _createTodoList(context),
            child: const Text('Utwórz'),
          ),
        ],
      ),
    );
  }
}
