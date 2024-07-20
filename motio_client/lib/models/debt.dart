import 'transaction.dart';
import 'user.dart';

class Debt {
  final int id;
  final User user1;
  final User user2;
  final List<Transaction> transactionHistories;
  final double balance;

  Debt({
    required this.id,
    required this.user1,
    required this.user2,
    required this.transactionHistories,
    required this.balance,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      user1: User.fromJson(json['user1']),
      user2: User.fromJson(json['user2']),
      transactionHistories: (json['transactionHistories'] as List)
          .map((item) => Transaction.fromJson(item, null))
          .toList(),
      balance: json['balance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1': user1.toJson(),
      'user2': user2.toJson(),
      'transactionHistories':
      transactionHistories.map((item) => item.toJsonWithoutDebt()).toList(),
      'balance': balance,
    };
  }
}
