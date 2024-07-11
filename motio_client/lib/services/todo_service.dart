import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo_list.dart';
import '../util/host_api_data.dart';
import 'base_service.dart';

class TodoService extends BaseService {
  static const String _todoListsUrl = "${HostApiData.baseCoreApiUrl}/todo-lists";

  Future<List<TodoList>> fetchAllTodoLists() async {
    final response = await sendAuthenticatedRequest(
        http.Request('GET', Uri.parse(_todoListsUrl))
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final List<dynamic> body = jsonDecode(decoded);
      return body.map((dynamic item) => TodoList.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load todo lists');
    }
  }

  Future<TodoList> getTodoListById(int id) async {
    final response = await sendAuthenticatedRequest(
        http.Request('GET', Uri.parse('$_todoListsUrl/$id'))
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      return TodoList.fromJson(jsonDecode(decoded));
    } else {
      throw Exception('Failed to load todo list');
    }
  }

  Future<TodoList> updateTodoList(int id, Map<String, dynamic> listData) async {
    final response = await sendAuthenticatedRequest(
        http.Request('PUT', Uri.parse('$_todoListsUrl/$id'))
          ..body = jsonEncode(listData)
    );

    if (response.statusCode == 200) {
      return TodoList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update todo list');
    }
  }

  Future<void> deleteTodoList(int id) async {
    final response = await sendAuthenticatedRequest(
        http.Request('DELETE', Uri.parse('$_todoListsUrl/$id'))
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete todo list');
    }
  }
}
