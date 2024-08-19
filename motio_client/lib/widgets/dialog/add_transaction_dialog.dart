import 'package:flutter/material.dart';

import '../../models/debt.dart';
import '../../models/user.dart';
import '../../services/debt_service.dart';

class AddTransactionDialog extends StatefulWidget {
  final Debt debt;
  final User currentUser;
  final VoidCallback onTransactionAdded;

  const AddTransactionDialog({
    Key? key,
    required this.debt,
    required this.currentUser,
    required this.onTransactionAdded,
  }) : super(key: key);

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  bool isCurrentUserOwes = true;
  bool _isAddingTransaction = false;
  bool _isAmountValid = true;

  final DebtService _debtService = DebtService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final otherUser = widget.currentUser.id == widget.debt.user1.id ? widget.debt.user2 : widget.debt.user1;
    final isDarkMode = theme.brightness == Brightness.dark;

    return AlertDialog(
      title: Text('Dodaj nową transakcję'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Tytuł'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: amountController,
            decoration: InputDecoration(labelText: 'Kwota'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final amount = double.tryParse(value);
              setState(() {
                _isAmountValid = amount != null && amount >= 0;
              });
            },
          ),
          const SizedBox(height: 10),
          Text('Kto jest dłużny', style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.secondary)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: isCurrentUserOwes,
                onChanged: (value) {
                  if (value != null && value) {
                    setState(() {
                      isCurrentUserOwes = true;
                    });
                  }
                },
                activeColor: theme.colorScheme.primary,
                checkColor: theme.colorScheme.onPrimary,
                side: BorderSide(color: theme.colorScheme.primary),
              ),
              Text('Ja', style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.secondary)),
              Checkbox(
                value: !isCurrentUserOwes,
                onChanged: (value) {
                  if (value != null && value) {
                    setState(() {
                      isCurrentUserOwes = false;
                    });
                  }
                },
                activeColor: theme.colorScheme.primary,
                checkColor: theme.colorScheme.onPrimary,
                side: BorderSide(color: theme.colorScheme.primary),
              ),
              Text('${otherUser.firstName} ${otherUser.lastName}',
                  style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.secondary)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Anuluj', style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.secondary)),
        ),
        TextButton(
          onPressed: _addTransaction,
          child: _isAddingTransaction
              ? CircularProgressIndicator()
              : Text('Dodaj',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  )),
        ),
      ],
    );
  }

  Future<void> _addTransaction() async {
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Podaj poprawną, nieujemną kwotę.')),
      );
      return;
    }

    setState(() {
      _isAddingTransaction = true;
    });

    User boundUser = widget.currentUser.id == widget.debt.user1.id ? widget.debt.user2 : widget.debt.user1;

    try {
      await _debtService.addTransaction(
        title: titleController.text,
        fromUser: isCurrentUserOwes ? boundUser : widget.currentUser,
        toUser: isCurrentUserOwes ? widget.currentUser : boundUser,
        amount: amount,
        debt: widget.debt,
      );
      widget.onTransactionAdded();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd dodawania transakcji: $e')),
      );
    } finally {
      setState(() {
        _isAddingTransaction = false;
      });

      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    titleController.dispose();
    super.dispose();
  }
}
