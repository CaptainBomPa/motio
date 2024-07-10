import 'shopping_item.dart';
import 'user.dart';

class ShoppingList {
  final int id;
  final String listName;
  final List<ShoppingItem> items;
  final User createdByUser;
  final List<User> accessibleUsers;

  ShoppingList({
    required this.id,
    required this.listName,
    required this.items,
    required this.createdByUser,
    required this.accessibleUsers,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'],
      listName: json['listName'],
      items: (json['items'] as List).map((i) => ShoppingItem.fromJson(i)).toList(),
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

  ShoppingList copyWith({
    int? id,
    String? listName,
    List<ShoppingItem>? items,
    User? createdByUser,
    List<User>? accessibleUsers,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      listName: listName ?? this.listName,
      items: items ?? this.items,
      createdByUser: createdByUser ?? this.createdByUser,
      accessibleUsers: accessibleUsers ?? this.accessibleUsers,
    );
  }
}
