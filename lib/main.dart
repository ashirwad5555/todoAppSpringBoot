import 'package:flutter/material.dart';
import 'models/todo.dart';
import 'services/todo_service.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.indigo.shade300, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
      home: const TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final TextEditingController _textController = TextEditingController();
  final TodoService _todoService = TodoService();
  List<Todo> _todos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  // Fetch todos from API
  Future<void> _fetchTodos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final todos = await _todoService.getAllTodos();
      setState(() {
        _todos = todos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        _showSnackBar('Error loading todos: ${e.toString()}');
      }
    }
  }

  // Add a new todo item
  Future<void> _addTodoItem() async {
    if (_textController.text.isEmpty) return;

    final newTodo = Todo(title: _textController.text, isDone: false);

    setState(() {
      _isLoading = true;
    });

    try {
      final createdTodo = await _todoService.createTodo(newTodo);
      setState(() {
        _todos.add(createdTodo);
        _isLoading = false;
      });
      _textController.clear();
      _showSnackBar('Task added successfully!', isError: false);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error adding todo: ${e.toString()}');
    }
  }

  // Clear all todo items
  Future<void> _clearTodoList() async {
    // Add confirmation dialog
    final bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                icon: Icon(
                  Icons.delete_sweep,
                  color: Colors.red.shade400,
                  size: 40,
                ),
                title: const Text(
                  '🧹 Clear All Tasks',
                  textAlign: TextAlign.center,
                ),
                content: const Text(
                  'This will remove all your tasks and cannot be undone. Are you sure you want to continue?',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('CANCEL'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('DELETE ALL'),
                        ),
                      ),
                    ],
                  ),
                ],
                actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              ),
        ) ??
        false;

    if (!confirm) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _todoService.deleteAllTodos();
      setState(() {
        _todos.clear();
        _isLoading = false;
      });
      _showSnackBar('All tasks cleared!', isError: false);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error clearing todos: ${e.toString()}');
    }
  }

  // Toggle the completion status of a todo item
  Future<void> _toggleTodoStatus(int index) async {
    final todo = _todos[index];
    final updatedTodo = Todo(
      id: todo.id,
      title: todo.title,
      isDone: !todo.isDone,
    );

    // Optimistic update for better UX
    setState(() {
      _todos[index] = updatedTodo;
    });

    try {
      final result = await _todoService.updateTodo(todo.id!, updatedTodo);
      setState(() {
        _todos[index] = result;
      });
    } catch (e) {
      // Revert on failure
      setState(() {
        _todos[index] = todo;
      });
      _showSnackBar('Error updating todo: ${e.toString()}');
    }
  }

  // Show snackbar helper
  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchTodos,
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All',
            onPressed: _clearTodoList,
          ),
        ],
      ),
      body: Column(
        children: [
          // Input area
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Add a new task',
                      prefixIcon: Icon(
                        Icons.task_alt,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onSubmitted: (_) => _addTodoItem(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTodoItem,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),

          // Todo list with loading indicator
          Expanded(
            child:
                _isLoading
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Loading tasks...',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                    : _todos.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet. Add some!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ReorderableListView.builder(
                      itemCount: _todos.length,
                      itemBuilder: (context, index) {
                        return _buildReorderableItem(index);
                      },
                      onReorder: _reorderTodo,
                      proxyDecorator:
                          (child, index, animation) => Material(
                            elevation: 4,
                            color: Colors.transparent,
                            shadowColor: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            child: child,
                          ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(int index, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: _todos[index].isDone,
              onChanged: (_) => _toggleTodoStatus(index),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              activeColor: Colors.green,
            ),
          ),
          title: Text(
            _todos[index].title,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  _todos[index].isDone ? FontWeight.normal : FontWeight.w500,
              decoration:
                  _todos[index].isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
              color:
                  _todos[index].isDone ? Colors.grey.shade500 : Colors.black87,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(index),
          ),
        ),
      ),
    );
  }

  Widget _buildReorderableItem(int index) {
    return Card(
      key: ValueKey(_todos[index].id),
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle indicator
            Icon(Icons.drag_indicator, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 8),
            // Checkbox
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: _todos[index].isDone,
                onChanged: (_) => _toggleTodoStatus(index),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: Colors.green,
              ),
            ),
          ],
        ),
        title: Text(
          _todos[index].title,
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                _todos[index].isDone ? FontWeight.normal : FontWeight.w500,
            decoration:
                _todos[index].isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
            color: _todos[index].isDone ? Colors.grey.shade500 : Colors.black87,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _confirmDelete(index),
        ),
      ),
    );
  }

  // Handle todo reordering
  void _reorderTodo(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        // Adjust index when moving down
        newIndex -= 1;
      }
      final item = _todos.removeAt(oldIndex);
      _todos.insert(newIndex, item);

      // Update position values
      for (int i = 0; i < _todos.length; i++) {
        _todos[i].position = i;
      }
    });

    // Show success message
    _showSnackBar('Task priority updated', isError: false);

    // Save the updated positions to backend
    _todoService.updateTodoPositions(_todos).catchError((e) {
      _showSnackBar('Error updating priority: ${e.toString()}');
    });
  }

  Future<void> _confirmDelete(int index) async {
    final bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  '🗑️ Delete Task',
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '"${_todos[index].title}"',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Are you sure you want to delete this task?',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('KEEP'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('DELETE'),
                        ),
                      ),
                    ],
                  ),
                ],
                actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              ),
        ) ??
        false;

    if (!confirm) return;

    try {
      // Optimistic delete
      final deletedTodo = _todos[index];
      setState(() {
        _todos.removeAt(index);
      });

      await _todoService.deleteTodo(deletedTodo.id!);
      _showSnackBar('Task deleted', isError: false);
    } catch (e) {
      _showSnackBar('Error deleting todo: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
