import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/debt.dart';
import '../services/debt_service.dart';

final debtServiceProvider = Provider<DebtService>((ref) {
  return DebtService();
});

final debtsProvider = FutureProvider<List<Debt>>((ref) async {
  final debtService = ref.watch(debtServiceProvider);
  return await debtService.getDebtsForUser();
});

final debtByIdProvider = FutureProvider.family<Debt, int>((ref, id) async {
  final debtService = ref.watch(debtServiceProvider);
  return await debtService.getDebtById(id);
});
