import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final List<Task> tasks = const [
    Task(
      title: "Projekt flutter",
      deadline: "jutro",
      done: true,
      priority: "wysoki",
    ),
    Task(
      title: "Ćwiczenia z matematyki",
      deadline: "dzisiaj",
      done: false,
      priority: "niski ",
    ),
    Task(
      title: "Przeczytac o widgetach",
      deadline: "w tym tygodniu",
      done: true,
      priority: "średni",
    ),
  ];

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final doneCount = tasks.where((task) => task.done).length;

    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(title: Text("Krakflow")),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Masz dziś ${tasks.length} zadania"),
              SizedBox(height: 25),
              Text("Wykonane zadania $doneCount"),
              SizedBox(height: 10),
              Text("Dzisiejsze zadania"),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      title: tasks[index].title,
                      subtitle:
                          "termin: ${tasks[index].deadline} | priorytet: ${tasks[index].priority}",
                      icon: (tasks[index].done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  const Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
