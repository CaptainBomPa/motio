import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../services/debt_service.dart';
import '../../services/user_service.dart';

class AddDebtDialog extends ConsumerStatefulWidget {
  final VoidCallback onDebtAdded;

  const AddDebtDialog({
    Key? key,
    required this.onDebtAdded,
  }) : super(key: key);

  @override
  _AddDebtDialogState createState() => _AddDebtDialogState();
}

class _AddDebtDialogState extends ConsumerState<AddDebtDialog> {
  final UserService _userService = UserService();
  final DebtService _debtService = DebtService();
  User? _selectedUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(userProvider);

    return FutureBuilder<List<User>>(
      future: _getAvailableUsers(currentUser!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Błąd: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Brak dostępnych użytkowników'));
        } else {
          final users = snapshot.data!;

          return Dialog(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: theme.primaryColor, width: 4),
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
                    'Stwórz nowy dług',
                    style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          title: Text('${user.firstName} ${user.lastName}'),
                          onTap: () {
                            setState(() {
                              _selectedUser = user;
                            });
                          },
                          selected: _selectedUser?.id == user.id,
                          selectedTileColor: theme.primaryColor.withOpacity(0.1),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Anuluj',
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: theme.textTheme.headlineLarge!.color,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _selectedUser == null
                            ? null
                            : () async {
                          try {
                            await _debtService.createDebt(currentUser, _selectedUser!);
                            widget.onDebtAdded();
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Błąd: $e')),
                            );
                          }
                        },
                        child: Text(
                          'Stwórz',
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: theme.textTheme.headlineLarge!.color,
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
        }
      },
    );
  }

  Future<List<User>> _getAvailableUsers(User currentUser) async {
    final allUsers = await _userService.getAllUsers();
    final allDebts = await _debtService.getDebtsForUser();

    final usersWithDebt = allDebts
        .map((debt) => debt.user1.id == currentUser.id ? debt.user2.id : debt.user1.id)
        .toSet();

    return allUsers
        .where((user) => user.id != currentUser.id && !usersWithDebt.contains(user.id))
        .toList();
  }
}
