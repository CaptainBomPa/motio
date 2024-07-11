import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motio_client/models/user.dart';
import '../models/todo_list.dart';
import '../providers/todo_list_provider.dart';
import '../services/todo_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/todo_list_tile.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = true;
  final TextEditingController _newListController = TextEditingController();
  final TodoService _todoService = TodoService();

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
    _loadTodoLists();
  }

  Future<void> _loadTodoLists() async {
    await ref.read(todoListProvider.future);
    setState(() {
      _isLoading = false;
    });
    _controller.forward();
  }

  Future<void> _refreshTodoLists() async {
    await ref.refresh(todoListProvider.future);
  }

  Future<void> _addNewTodoList(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Utwórz nową listę TODO'),
          content: TextField(
            controller: _newListController,
            decoration: InputDecoration(
              labelText: 'Nazwa listy',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Anuluj'),
            ),
            TextButton(
              onPressed: () async {
                final listName = _newListController.text.trim();
                if (listName.isNotEmpty) {
                  final newTodoList = TodoList(
                      id: 0,
                      listName: listName,
                      items: [],
                      accessibleUsers: [],
                      createdByUser: User(id: 0,
                          username: '',
                          firstName: '',
                          lastName: '',
                          email: ''));
                  try {
                    await _todoService.createTodoList(newTodoList.toJson());
                    ref.invalidate(todoListProvider);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lista TODO została utworzona.')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Błąd podczas tworzenia listy TODO: $e')),
                    );
                  }
                }
              },
              child: Text('Utwórz'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _newListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoListAsyncValue = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista TODO'),
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
