import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_list_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dialog/new_todo_list_dialog.dart';
import '../widgets/todo_list_tile.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _loadTodoLists();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadTodoLists() async {
    await ref.read(todoListProvider.future);
    setState(() {
      _isLoading = false;
    });
    _controller.forward();
  }

  Future<void> _refreshTodoLists() async {
    ref.invalidate(todoListProvider);
  }

  Future<void> _addNewTodoList(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const NewTodoListDialog();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoListAsyncValue = ref.watch(todoListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addNewTodoList(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : todoListAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Wystąpił błąd: $error')),
              data: (todoLists) {
                return RefreshIndicator(
                  onRefresh: _refreshTodoLists,
                  child: FadeTransition(
                    opacity: _animation,
                    child: ListView.builder(
                      itemCount: todoLists.length,
                      itemBuilder: (context, index) {
                        final todoList = todoLists[index];
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.1),
                            end: Offset.zero,
                          ).animate(_animation),
                          child: TodoListTile(todoList: todoList),
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
