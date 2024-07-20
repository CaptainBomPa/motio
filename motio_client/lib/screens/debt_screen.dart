import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/debt_provider.dart';
import '../services/debt_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/debt_list_tile.dart';
import '../widgets/dialog/add_debt_dialog.dart'; // Import the AddDebtDialog
import 'debt_details_screen.dart'; // Import the DebtDetailsScreen

class DebtScreen extends ConsumerStatefulWidget {
  const DebtScreen({super.key});

  @override
  _DebtScreenState createState() => _DebtScreenState();
}

class _DebtScreenState extends ConsumerState<DebtScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = true;
  final DebtService _debtService = DebtService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    await ref.read(debtsProvider.future);
    setState(() {
      _isLoading = false;
    });
    _controller.forward();
  }

  Future<void> _refreshDebts() async {
    print('onRefresh');
    setState(() {
      _isLoading = true;
    });
    await ref.refresh(debtsProvider.future);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debtListAsyncValue = ref.watch(debtsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Splitter'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddDebtDialog(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : debtListAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Wystąpił błąd: $error')),
        data: (debts) {
          return RefreshIndicator(
            onRefresh: _refreshDebts,
            child: FadeTransition(
              opacity: _animation,
              child: ListView.builder(
                itemCount: debts.length,
                itemBuilder: (context, index) {
                  final debt = debts[index];
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.1),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DebtDetailsScreen(debt: debt),
                          ),
                        );
                      },
                      child: DebtListTile(debt: debt, onBack: _refreshDebts,),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddDebtDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddDebtDialog(
          onDebtAdded: () async {
            await _refreshDebts();
          },
        );
      },
    );
  }
}
