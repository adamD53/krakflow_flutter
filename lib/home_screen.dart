import 'package:flutter/material.dart';
import 'task_repository.dart';
import 'task_api_service.dart';
import 'edit_task_screen.dart';
import 'add_task_screen.dart';
import 'task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'wszystkie';
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasksFromApi();
  }

  Future<void> _loadTasksFromApi() async {
    try {
      final tasks = await TaskApiService.fetchTasks();
      setState(() {
        TaskRepository.tasks = tasks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<Task> get filteredTasks {
    if (selectedFilter == 'wykonane') {
      return TaskRepository.tasks.where((t) => t.done).toList();
    } else if (selectedFilter == 'do zrobienia') {
      return TaskRepository.tasks.where((t) => !t.done).toList();
    }
    return TaskRepository.tasks;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final total = TaskRepository.tasks.length;
    final doneCount = TaskRepository.tasks.where((t) => t.done).length;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('KrakFlow')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('KrakFlow')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Błąd: $errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _loadTasksFromApi();
                },
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('KrakFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: TaskRepository.tasks.isEmpty
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Potwierdzenie'),
                          content: const Text(
                            'Czy na pewno chcesz usunąć wszystkie zadania?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Anuluj'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Usuń'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed == true) {
                      setState(() {
                        TaskRepository.tasks.clear();
                      });
                      _showSnack('Wszystkie zadania usunięte');
                    }
                  },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masz dziś $total zadania'),
            const SizedBox(height: 8),
            Text('Wykonane zadania $doneCount'),
            const SizedBox(height: 8),
            Row(
              children: [
                _filterButton('wszystkie', 'Wszystkie'),
                _filterButton('do zrobienia', 'Do zrobienia'),
                _filterButton('wykonane', 'Wykonane'),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Dzisiejsze zadania'),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];

                  return Dismissible(
                    key: ValueKey(task.title + index.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        final repoIndex = TaskRepository.tasks.indexOf(task);
                        if (repoIndex != -1) {
                          TaskRepository.tasks.removeAt(repoIndex);
                        }
                      });
                      _showSnack('Usunięto zadanie: ${task.title}');
                    },
                    child: TaskCard(
                      title: task.title,
                      subtitle:
                          'termin: ${task.deadline} | priorytet: ${task.priority}',
                      done: task.done,
                      onChanged: (val) {
                        setState(() {
                          final repoIndex = TaskRepository.tasks.indexOf(task);
                          if (repoIndex != -1) {
                            TaskRepository.tasks[repoIndex].done = val ?? false;
                          }
                        });
                      },
                      onTap: () async {
                        final Task? updated = await Navigator.push<Task>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTaskScreen(task: task),
                          ),
                        );
                        if (updated != null) {
                          setState(() {
                            final repoIndex = TaskRepository.tasks.indexOf(
                              task,
                            );
                            if (repoIndex != -1) {
                              TaskRepository.tasks[repoIndex] = updated;
                            }
                          });
                          _showSnack('Zaktualizowano zadanie');
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push<Task>(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const AddTaskScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
            ),
          );

          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
            _showSnack('Dodano zadanie: ${newTask.title}');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterButton(String key, String label) {
    final active = selectedFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedFilter = key;
          });
        },
        style: TextButton.styleFrom(
          foregroundColor: active ? Colors.white : null,
          backgroundColor: active
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
        child: Text(label),
      ),
    );
  }
}
