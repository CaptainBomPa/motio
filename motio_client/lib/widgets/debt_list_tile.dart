import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/debt.dart';
import '../providers/user_provider.dart';
import '../screens/debt_details_screen.dart';

class DebtListTile extends ConsumerWidget {
  final Debt debt;
  final VoidCallback onBack;

  DebtListTile({super.key, required this.debt, required this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(userProvider);

    final isUser1 = currentUser?.id == debt.user1.id;
    final otherUser = isUser1 ? debt.user2 : debt.user1;
    final userBalance = isUser1 ? debt.balance : -debt.balance;
    final balanceColor = userBalance < 0 ? Colors.red : Colors.green;

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          otherUser.firstName[0] + otherUser.lastName[0],
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
      title: Text(
        '${otherUser.firstName} ${otherUser.lastName}',
        style: theme.textTheme.bodyLarge, // Zastosowanie stylu motywu
      ),
      trailing: Hero(
        tag: 'debt-${debt.id}',
        child: Text(
          '${userBalance.toStringAsFixed(2)} PLN',
          style: theme.textTheme.bodyLarge?.copyWith(color: balanceColor), // Zastosowanie stylu motywu z kolorem
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DebtDetailsScreen(debt: debt),
          ),
        ).then((_) {onBack();});
      },
    );
  }
}
