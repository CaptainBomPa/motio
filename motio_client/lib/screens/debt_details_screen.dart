import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import '../models/debt.dart';
import '../models/transaction.dart';
import '../providers/user_provider.dart';
import '../services/debt_service.dart';
import 'add_transaction_screen.dart';

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
        title: Text(
          'Szczegóły długu',
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
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () =>
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        AddTransactionScreen(
                          debt: _debt,
                          currentUser: currentUser!,
                          onTransactionAdded: () async {
                            await _refreshDebtDetails();
                          },
                        ),
                  ),
                ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const Svg('assets/main/dialog_background.svg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.55), BlendMode.lighten),
          ),
        ),
        child: Column(
          children: [
            Hero(
              tag: 'debt-${_debt.id}',
              child: Container(
                margin: const EdgeInsets.all(16.0),
                child: Text(
                  '${userBalance.toStringAsFixed(2)} PLN',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: balanceColor,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(0, 0),
                        blurRadius: 2,
                      ),
                    ],
                  ),
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
                  final formattedDate =
                      "${transaction.transactionDate.day.toString().padLeft(2, '0')}-${transaction.transactionDate.month
                      .toString().padLeft(2, '0')}-${transaction.transactionDate.year} ${transaction.transactionDate.hour
                      .toString().padLeft(2, '0')}:${transaction.transactionDate.minute.toString().padLeft(2, '0')}";

                  return ListTile(
                    title: Text(transaction.title,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${!isCurrentUserTransaction ? "-" : ""} ${transaction.amount.toStringAsFixed(2)} PLN',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: transactionColor,
                            shadows: [
                              const Shadow(
                                color: Colors.black,
                                offset: Offset(0, 0),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        Text(formattedDate, style: theme.textTheme.bodySmall),
                      ],
                    ),
                    onLongPress: () => _showTransactionOptions(context, transaction),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionOptions(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Modyfikuj'),
              onTap: () {
                Navigator.of(context).pop();
                _showEditTransactionDialog(context, transaction);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Usuń'),
              onTap: () {
                Navigator.of(context).pop();
                _confirmDeleteTransaction(context, transaction);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditTransactionDialog(BuildContext context, Transaction transaction) {
    final TextEditingController amountController = TextEditingController(text: transaction.amount.toString());
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme
                .of(context)
                .primaryColor, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const Svg('assets/main/dialog_background.svg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.6), BlendMode.lighten),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edytuj transakcję',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Kwota',
                    fillColor: Colors.white.withOpacity(0.7),
                    filled: true,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Anuluj',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                          color: Theme
                              .of(context)
                              .textTheme
                              .headlineLarge!
                              .color,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final amount = double.tryParse(amountController.text);
                        if (amount == null || amount < 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Podaj poprawną, nieujemną kwotę.')),
                          );
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          await _debtService.updateTransaction(
                            id: transaction.id,
                            title: transaction.title,
                            fromUser: transaction.fromUser,
                            toUser: transaction.toUser,
                            amount: amount,
                            debt: _debt,
                          );
                          await _refreshDebtDetails();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Błąd podczas aktualizacji transakcji: \$e')),
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        'Zapisz',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                          color: Theme
                              .of(context)
                              .textTheme
                              .headlineLarge!
                              .color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteTransaction(BuildContext context, Transaction transaction) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme
                .of(context)
                .primaryColor, width: 4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const Svg('assets/main/dialog_background.svg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.6), BlendMode.lighten),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Usuń transakcję',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Czy na pewno chcesz usunąć tę transakcję?',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium,
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Anuluj',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                          color: Theme
                              .of(context)
                              .textTheme
                              .headlineLarge!
                              .color,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        // Start loading indicator
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          await _debtService.deleteTransaction(transaction.id);
                          await _refreshDebtDetails();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Błąd podczas usuwania transakcji: $e')),
                          );
                        } finally {
                          // Stop loading indicator
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      child: Text(
                        'Usuń',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                          color: Theme
                              .of(context)
                              .textTheme
                              .headlineLarge!
                              .color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
