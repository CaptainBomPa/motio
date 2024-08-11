import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool _isLoading = false;
  User? _selectedUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(userProvider);

    return AlertDialog(
      title: const Text('Stwórz nowy dług'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<User>>(
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

            // Upewnij się, że _selectedUser jest jednym z dostępnych użytkowników
            if (_selectedUser != null &&
                !users.any((user) => user.id == _selectedUser!.id)) {
              _selectedUser = null; // Reset, jeśli nie ma zgodności
            }

            return DropdownButton<User>(
              value: _selectedUser,
              hint: const Text('Wybierz użytkownika'),
              onChanged: (User? newValue) {
                setState(() {
                  _selectedUser = newValue;
                });
              },
              items: users.map<DropdownMenuItem<User>>((User user) {
                return DropdownMenuItem<User>(
                  value: user,
                  child: Text('${user.firstName} ${user.lastName}'),
                );
              }).toList(),
            );
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Anuluj', style: theme.textTheme.bodyMedium),
        ),
        TextButton(
          onPressed: _selectedUser == null
              ? null
              : () async {
            setState(() {
              _isLoading = true;
            });

            try {
              await _debtService.createDebt(currentUser!, _selectedUser!);
              widget.onDebtAdded();
              Navigator.of(context).pop();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Błąd: $e')),
              );
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text('Stwórz', style: theme.textTheme.bodyMedium),
        ),
      ],
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
