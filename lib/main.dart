import 'package:flutter/material.dart';
import 'task_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrakFlow',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'wszystkie';

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

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: done, onChanged: onChanged),
        title: Text(
          title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    deadlineController.dispose();
    priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nowe zadanie')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tytuł zadania',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: 'Termin',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(
                labelText: 'Priorytet',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: priorityController.text.isEmpty
                      ? 'niski'
                      : priorityController.text,
                );
                Navigator.pop(context, newTask);
              },
              child: const Text('Zapisz'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController deadlineController;
  late TextEditingController priorityController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    deadlineController = TextEditingController(text: widget.task.deadline);
    priorityController = TextEditingController(text: widget.task.priority);
  }

  @override
  void dispose() {
    titleController.dispose();
    deadlineController.dispose();
    priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edycja zadania')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tytuł zadania',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: 'Termin',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(
                labelText: 'Priorytet',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final updated = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: widget.task.done,
                  priority: priorityController.text.isEmpty
                      ? 'niski'
                      : priorityController.text,
                );
                Navigator.pop(context, updated);
              },
              child: const Text('Zapisz'),
            ),
          ],
        ),
      ),
    );
  }
}
