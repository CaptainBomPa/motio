import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

import '../providers/debt_provider.dart';
import '../services/debt_service.dart';
import '../widgets/debt_list_tile.dart';
import '../widgets/dialog/add_debt_dialog.dart';
import 'debt_details_screen.dart';

class DebtScreen extends ConsumerStatefulWidget {
  const DebtScreen({super.key});

  @override
  ConsumerState<DebtScreen> createState() => _DebtScreenState();
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Svg('assets/main/home_body.svg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
        ),
        child: _isLoading
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
                        child: DebtListTile(debt: debt, onBack: _refreshDebts),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(context),
        child: const Icon(Icons.add),
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