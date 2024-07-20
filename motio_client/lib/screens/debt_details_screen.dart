import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/debt.dart';
import '../providers/user_provider.dart';
import '../services/debt_service.dart';
import '../widgets/dialog/add_transaction_dialog.dart';

class DebtDetailsScreen extends ConsumerStatefulWidget {
  final Debt debt;

  const DebtDetailsScreen({super.key, required this.debt});

  @override
  _DebtDetailsScreenState createState() => _DebtDetailsScreenState();
}

class _DebtDetailsScreenState extends ConsumerState<DebtDetailsScreen> {
  final DebtService _debtService = DebtService();
  bool _isLoading = false;
  late Debt _debt;

  @override
  void initState() {
    super.initState();
    _debt = widget.debt;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(userProvider);

    final isUser1 = currentUser?.id == _debt.user1.id;
    final userBalance = isUser1 ? _debt.balance : -_debt.balance;
    final balanceColor = userBalance < 0 ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text('Szczegóły długu'),
        actions: [
          _isLoading
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          )
              : IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Hero(
            tag: 'debt-${_debt.id}',
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: Text(
                '${userBalance.toStringAsFixed(2)} PLN',
                style: theme.textTheme.headlineLarge?.copyWith(color: balanceColor),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _debt.transactionHistories.length,
              itemBuilder: (context, index) {
                final transaction = _debt.transactionHistories[index];
                final isCurrentUserTransaction = transaction.fromUser.id == currentUser?.id;
                final transactionColor = isCurrentUserTransaction ? Colors.green : Colors.red;
                final formattedDate = "${transaction.transactionDate.day.toString().padLeft(2, '0')}-${transaction.transactionDate.month.toString().padLeft(2, '0')}-${transaction.transactionDate.year} ${transaction.transactionDate.hour.toString().padLeft(2, '0')}:${transaction.transactionDate.minute.toString().padLeft(2, '0')}";

                return ListTile(
                  title: Text(transaction.title, style: theme.textTheme.bodyLarge),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${!isCurrentUserTransaction ? "-" : ""} ${transaction.amount.toStringAsFixed(2)} PLN',
                        style: theme.textTheme.bodyLarge?.copyWith(color: transactionColor),
                      ),
                      Text(formattedDate, style: theme.textTheme.bodySmall),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTransactionDialog(
          debt: _debt,
          currentUser: ref.watch(userProvider)!,
          onTransactionAdded: () async {
            await _refreshDebtDetails();
          },
        );
      },
    );
  }

  Future<void> _refreshDebtDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final updatedDebt = await _debtService.getDebtById(_debt.id);
      setState(() {
        _debt = updatedDebt;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas odświeżania danych: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
