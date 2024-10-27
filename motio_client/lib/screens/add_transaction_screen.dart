import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import '../models/debt.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/debt_service.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final Debt debt;
  final User currentUser;
  final VoidCallback onTransactionAdded;

  const AddTransactionScreen({
    Key? key,
    required this.debt,
    required this.currentUser,
    required this.onTransactionAdded,
  }) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dodaj nową transakcję',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: Svg('assets/main/app_bar.svg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const Svg('assets/main/dialog_background.svg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.55), BlendMode.lighten),
          ),
        ),
        padding: const EdgeInsets.only(top: 26.0, left: 16.0, right: 16.0),
        child: Column(
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
            const SizedBox(height: 20),
            _isAddingTransaction
                ? CircularProgressIndicator()
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor
              ),
              onPressed: _addTransaction,
              child: Text('Dodaj',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        ),
      ),
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
