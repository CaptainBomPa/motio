import 'debt.dart';
import 'user.dart';

class Transaction {
  final int id;
  final String title;
  final User fromUser;
  final User toUser;
  final double amount;
  final DateTime transactionDate;
  final Debt? debt;

  Transaction({
    required this.id,
    required this.title,
    required this.fromUser,
    required this.toUser,
    required this.amount,
    required this.transactionDate,
    this.debt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json, Debt? debt) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      fromUser: User.fromJson(json['fromUser']),
      toUser: User.fromJson(json['toUser']),
      amount: json['amount'],
      transactionDate: DateTime.parse(json['transactionDate']),
      debt: debt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fromUser': fromUser.toJson(),
      'toUser': toUser.toJson(),
      'amount': amount,
      'transactionDate': transactionDate.toIso8601String(),
      'debt': debt?.toJson(),
    };
  }

  Map<String, dynamic> toJsonWithoutDebt() {
    return {
      'id': id,
      'title': title,
      'fromUser': fromUser.toJson(),
      'toUser': toUser.toJson(),
      'amount': amount,
      'transactionDate': transactionDate.toIso8601String(),
    };
  }
}
