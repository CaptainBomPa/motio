import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_list.dart';
import '../models/todo_item.dart';
import '../models/user.dart';
import '../services/todo_service.dart';
import 'user_provider.dart';

final todoListDetailProvider = StateNotifierProvider.family<TodoListDetailNotifier, TodoList, int>((ref, id) {
  final todoService = TodoService();
  return TodoListDetailNotifier(todoService, id);
});

class TodoListDetailNotifier extends StateNotifier<TodoList> {
  final TodoService _todoService;
  final int _id;

  TodoListDetailNotifier(this._todoService, this._id) : super(TodoList(id: _id,
      listName: '',
      items: [],
      createdByUser: User(id: 0,
          username: '',
          firstName: '',
          lastName: '',
          email: ''),
      accessibleUsers: [])) {
    _loadTodoList();
  }

  Future<void> _loadTodoList() async {
    final todoList = await _todoService.getTodoListById(_id);
    state = todoList;
  }

  void addItem(TodoItem item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  void updateItem(TodoItem item) {
    state = state.copyWith(
      items: state.items.map((i) => i.id == item.id ? item : i).toList(),
    );
  }

  void removeItem(int itemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != itemId).toList(),
    );
  }

  void toggleItemChecked(int itemId) {
    final items = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(checked: !item.checked);
      }
      return item;
    }).toList();

    state = state.copyWith(items: items);
  }

  void reorderItems(int oldIndex, int newIndex) {
    final items = [...state.items];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    state = state.copyWith(items: items);
  }

  Future<void> saveTodoList() async {
    await _todoService.updateTodoList(state.id, state.toJson());
  }
}
