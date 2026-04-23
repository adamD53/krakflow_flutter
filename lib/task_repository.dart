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

class TaskRepository {
  static List<Task> tasks = [
    const Task(
      title: 'Projekt Flutter',
      deadline: 'jutro',
      done: false,
      priority: 'wysoki',
    ),
    const Task(
      title: 'Oddac raport',
      deadline: 'dzisiaj',
      done: true,
      priority: 'wysoki',
    ),
    const Task(
      title: 'Powtorzyc widgety',
      deadline: 'w piatek',
      done: false,
      priority: 'sredni',
    ),
  ];
}
