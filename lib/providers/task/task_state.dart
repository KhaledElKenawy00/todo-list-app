import 'package:equatable/equatable.dart';
import 'package:todo_list_app/data/models/task.dart';

class TaskState extends Equatable {
  final List<Task> tasks;

  const TaskState({required this.tasks});
  const TaskState.initial({this.tasks = const []});

  TaskState copyWith({List<Task>? tasks}) {
    return TaskState(tasks: tasks ?? this.tasks);
  }

  @override
  List<Object> get props => [tasks];
}
