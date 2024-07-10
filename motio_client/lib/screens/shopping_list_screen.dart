import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/shopping_list_tile.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = true;

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
    _loadShoppingLists();
  }

  Future<void> _loadShoppingLists() async {
    await ref.read(shoppingListProvider.future);
    setState(() {
      _isLoading = false;
    });
    _controller.forward();
  }

  Future<void> _refreshShoppingLists() async {
    await ref.refresh(shoppingListProvider.future);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shoppingListAsyncValue = ref.watch(shoppingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista zakupów'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : shoppingListAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Wystąpił błąd: $error')),
        data: (shoppingLists) {
          return RefreshIndicator(
            onRefresh: _refreshShoppingLists,
            child: FadeTransition(
              opacity: _animation,
              child: ListView.builder(
                itemCount: shoppingLists.length,
                itemBuilder: (context, index) {
                  final shoppingList = shoppingLists[index];
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.1),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: ShoppingListTile(shoppingList: shoppingList),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
