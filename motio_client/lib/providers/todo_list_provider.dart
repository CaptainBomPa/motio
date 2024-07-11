import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_list.dart';
import '../services/todo_service.dart';

final todoListProvider = FutureProvider<List<TodoList>>((ref) async {
  final todoService = TodoService();
  return await todoService.fetchAllTodoLists();
});
