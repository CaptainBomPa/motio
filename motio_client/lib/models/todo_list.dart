import 'todo_item.dart';
import 'user.dart';

class TodoList {
  final int id;
  final String listName;
  final List<TodoItem> items;
  final User createdByUser;
  final List<User> accessibleUsers;

  TodoList({
    required this.id,
    required this.listName,
    required this.items,
    required this.createdByUser,
    required this.accessibleUsers,
  });

  factory TodoList.fromJson(Map<String, dynamic> json) {
    return TodoList(
      id: json['id'],
      listName: json['listName'],
      items: (json['items'] as List).map((i) => TodoItem.fromJson(i)).toList(),
      createdByUser: User.fromJson(json['createdByUser']),
      accessibleUsers: (json['accessibleUsers'] as List).map((u) => User.fromJson(u)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listName': listName,
      'items': items.map((i) => i.toJson()).toList(),
      'createdByUser': createdByUser.toJson(),
      'accessibleUsers': accessibleUsers.map((u) => u.toJson()).toList(),
    };
  }

  TodoList copyWith({
    int? id,
    String? listName,
    List<TodoItem>? items,
    User? createdByUser,
    List<User>? accessibleUsers,
  }) {
    return TodoList(
      id: id ?? this.id,
      listName: listName ?? this.listName,
      items: items ?? this.items,
      createdByUser: createdByUser ?? this.createdByUser,
      accessibleUsers: accessibleUsers ?? this.accessibleUsers,
    );
  }
}
