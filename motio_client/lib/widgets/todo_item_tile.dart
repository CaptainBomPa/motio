import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class TodoItemTile extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onItemCheckedToggle;
  final VoidCallback onItemDelete;

  const TodoItemTile({
    super.key,
    required this.item,
    required this.onItemCheckedToggle,
    required this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      key: Key(item.id.toString()),
      title: Text(
        item.description,
        style: TextStyle(
          decoration: item.checked ? TextDecoration.lineThrough : null,
          fontWeight: item.checked ? null : FontWeight.bold,
          color: theme.primaryColor,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: item.checked,
            onChanged: (_) => onItemCheckedToggle(),
            side: BorderSide(color: theme.colorScheme.primary),
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: theme.colorScheme.primary,
            ),
            onPressed: onItemDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
