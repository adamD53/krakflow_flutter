import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'task_repository.dart';

class TaskApiService {
  static const String _apiUrl = 'https://dummyjson.com/todos';
  static final Random _random = Random();
  static const List<String> _priorities = ['niski', 'średni', 'wysoki'];

  static Future<List<Task>> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final todos = jsonData['todos'] as List;

        final tasks = todos.map((todo) {
          return Task(
            title: todo['todo'] ?? 'Bez tytułu',
            deadline: _generateRandomDeadline(),
            done: todo['completed'] ?? false,
            priority: _generateRandomPriority(),
          );
        }).toList();

        return tasks;
      } else {
        throw Exception(
          'Nie udało się pobrać zadań. Kod: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Błąd sieciowy: $e');
    }
  }

  static String _generateRandomPriority() {
    return _priorities[_random.nextInt(_priorities.length)];
  }

  static String _generateRandomDeadline() {
    final deadlines = [
      'dzisiaj',
      'jutro',
      'w poniedziałek',
      'w wtorek',
      'w środę',
      'w czwartek',
      'w piątek',
      'w weekend',
      'za tydzień',
      'za dwa tygodnie',
    ];
    return deadlines[_random.nextInt(deadlines.length)];
  }
}
