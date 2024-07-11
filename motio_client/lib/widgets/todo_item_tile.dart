import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class TodoItemTile extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onItemCheckedToggle;
  final VoidCallback onItemDelete;

  const TodoItemTile({
    Key? key,
    required this.item,
    required this.onItemCheckedToggle,
    required this.onItemDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      key: Key(item.id.toString()),
      title: Text(
        item.description,
        style: TextStyle(
          decoration: item.checked ? TextDecoration.lineThrough : null,
          color: item.checked ? theme.textTheme.bodyMedium!.color!.withOpacity(0.5) : theme.textTheme.bodyMedium!.color,
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
          ),
        ],
      ),
    );
  }
}
