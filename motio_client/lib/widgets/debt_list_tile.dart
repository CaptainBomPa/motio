import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import '../models/debt.dart';
import '../providers/user_provider.dart';
import '../screens/debt_details_screen.dart';

class DebtListTile extends ConsumerWidget {
  final Debt debt;
  final VoidCallback onBack;

  const DebtListTile({super.key, required this.debt, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(userProvider);

    final isUser1 = currentUser?.id == debt.user1.id;
    final otherUser = isUser1 ? debt.user2 : debt.user1;
    final userBalance = isUser1 ? debt.balance : -debt.balance;
    final balanceColor = userBalance < 0 ? Colors.red : Colors.green;
    final lastTransaction = debt.transactionHistories.isNotEmpty
        ? debt.transactionHistories.last.transactionDate
        : null;
    final lastTransactionText = lastTransaction != null
        ? 'Ostatnia transakcja: ${lastTransaction.toLocal().toString().substring(0, 16)}'
        : 'Brak transakcji';

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          margin: const EdgeInsets.only(left: 12.0, right: 12.0, top: 6.0, bottom: 6.0),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[50]?.withOpacity(0.9),
            border: Border.all(
              color: theme.primaryColor,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple[300]!,
                blurRadius: 4,
                offset: const Offset(6, 8),
              ),
            ],
            image: const DecorationImage(
              image: Svg('assets/main/notification_background.svg'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${otherUser.firstName} ${otherUser.lastName}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Hero(
                    tag: 'debt-${debt.id}',
                    child: Text(
                      '${userBalance.toStringAsFixed(2)} PLN',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: balanceColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            offset: Offset(0, 0),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                lastTransactionText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
