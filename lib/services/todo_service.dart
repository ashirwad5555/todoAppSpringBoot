import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class TodoService {
  // Change this to your backend URL (use your machine's IP if running on emulator)
  static const String baseUrl = 'http://192.168.177.134:8080/api/todos';

  // Get all todos
  Future<List<Todo>> getAllTodos() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Todo.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  // Create a new todo
  Future<Todo> createTodo(Todo todo) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create todo');
    }
  }

  // Update todo
  Future<Todo> updateTodo(String id, Todo todo) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()),
    );

    if (response.statusCode == 200) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update todo');
    }
  }

  // Delete todo
  Future<void> deleteTodo(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo');
    }
  }

  // Delete all todos
  Future<void> deleteAllTodos() async {
    final response = await http.delete(Uri.parse(baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete todos');
    }
  }

  // Update todo positions
  Future<List<Todo>> updateTodoPositions(List<Todo> todos) async {
    final response = await http.put(
      Uri.parse('$baseUrl/positions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todos.map((todo) => todo.toJson()).toList()),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Todo.fromJson(item)).toList();
    } else {
      throw Exception('Failed to update todo positions');
    }
  }
}
