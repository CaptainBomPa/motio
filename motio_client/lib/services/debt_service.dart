import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:motio_client/models/user.dart';

import '../models/debt.dart';
import '../models/transaction.dart';
import '../util/host_api_data.dart';
import 'base_service.dart';

class DebtService extends BaseService {
  static const String _debtsUrl = "${HostApiData.baseCoreApiUrl}/debts";
  static const String _transactionsUrl = "${HostApiData.baseCoreApiUrl}/debts/transaction";

  Future<void> createDebt(User user1, User user2) async {
    final response = await sendAuthenticatedRequest(
      http.Request(
        'POST',
        Uri.parse(_debtsUrl),
      )
        ..body = jsonEncode({
          'user1': user1,
          'user2': user2,
        }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create debt');
    }
  }

  Future<Transaction> addTransaction({
    required String title,
    required User fromUser,
    required User toUser,
    required double amount,
    required Debt debt,
  }) async {
    final response = await sendAuthenticatedRequest(
      http.Request('POST', Uri.parse(_transactionsUrl))
        ..headers['Content-Type'] = 'application/json; charset=UTF-8'
        ..body = jsonEncode({
          'title': title,
          'fromUser': fromUser,
          'toUser': toUser,
          'amount': amount,
          'debt': debt,
        }),
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body), null);
    } else {
      throw Exception('Failed to add transaction');
    }
  }

  Future<Transaction> updateTransaction({
    required int id,
    required String title,
    required User fromUser,
    required User toUser,
    required double amount,
    required Debt debt,
  }) async {
    final response = await sendAuthenticatedRequest(
      http.Request('PUT', Uri.parse(_transactionsUrl))
        ..headers['Content-Type'] = 'application/json; charset=UTF-8'
        ..body = jsonEncode({
          'id': id,
          'title': title,
          'fromUser': fromUser,
          'toUser': toUser,
          'amount': amount,
          'debt': debt,
        }),
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body), null);
    } else {
      throw Exception('Failed to update transaction');
    }
  }

  Future<void> deleteTransaction(int id) async {
    final response = await sendAuthenticatedRequest(
      http.Request('DELETE', Uri.parse('$_transactionsUrl/$id'))
        ..headers['Content-Type'] = 'application/json; charset=UTF-8',
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete transaction');
    }
  }

  Future<List<Debt>> getDebtsForUser() async {
    final response = await sendAuthenticatedRequest(
      http.Request('GET', Uri.parse(_debtsUrl)),
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final List<dynamic> body = jsonDecode(decoded);
      return body.map((dynamic item) => Debt.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load debts');
    }
  }

  Future<Debt> getDebtById(int id) async {
    final response = await sendAuthenticatedRequest(
      http.Request('GET', Uri.parse('$_debtsUrl/$id')),
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      return Debt.fromJson(jsonDecode(decoded));
    } else {
      throw Exception('Failed to load debt');
    }
  }
}
