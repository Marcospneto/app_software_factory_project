import 'package:collection/collection.dart';
import 'package:meu_tempo/locator/locator.dart';
import 'package:meu_tempo/models/task.dart';
import 'package:meu_tempo/repositories/task_repository.dart';
import 'package:meu_tempo/services/users_service.dart';
import 'package:mobx/mobx.dart';

part 'task_store.g.dart';

class TaskStore = _TaskStore with _$TaskStore;

abstract class _TaskStore with Store {
  final TaskRepository taskRepository = getIt<TaskRepository>();
  final UsersService userService = getIt<UsersService>();

  @observable
  ObservableList<Task> monthlyTasks = ObservableList<Task>();

  @observable
  ObservableMap<String, DayTaskStatus> taskStatusPerDay = ObservableMap();

  @observable
  bool isLoading = false;

  @action
  Future<void> fetchTask(String date) async {
    isLoading = true;
    final taskList = await taskRepository.getTasksByDate(date);
    monthlyTasks = taskList.asObservable();
    isLoading = false;
  }

  @action
  Future<void> fetchTasksByMonth(DateTime date) async {
    isLoading = true;
    try {
      final user = await userService.getCurrentUser();

      if (user != null && user.id != null) {
        final startDate = DateTime(date.year, date.month, 1);
        final endDate = DateTime(date.year, date.month + 1, 0);

        final allUserTasks =
            await taskRepository.fetchTaskUser(user.id.toString());

        final tasksInRange = await taskRepository.fetchTasksByDateRange(
          userId: user.id.toString(),
          startDate: startDate,
          endDate: endDate,
        );

        monthlyTasks = tasksInRange.asObservable();
      } else {
        monthlyTasks.clear();
      }

      _calculateTaskStatusForMonth();
    } catch (e) {
      print('Erro ao buscar tarefas do mês: $e');
      monthlyTasks.clear();
      taskStatusPerDay.clear();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> addTask(Task task) async {
    try {
      isLoading = true;
      await taskRepository.addItem(task);
      await fetchTasksByMonth(DateTime.now());
    } catch (e) {
      print('Erro ao adicionar tarefa: $e');
      throw Exception('Erro ao adicionar tarefa');
    } finally {
      isLoading = false;
    }
  }

  @action
  void _calculateTaskStatusForMonth() {
    final groupedTasks = groupBy(monthlyTasks, (Task task) => task.date);

    final newStatusMap = <String, DayTaskStatus>{};

    groupedTasks.forEach((dateString, tasksOnDay) {
      if (tasksOnDay.isNotEmpty) {
        final allCompleted = tasksOnDay.every((task) => task.completed);
        newStatusMap[dateString] = DayTaskStatus(
          tasksExist: true,
          allTasksCompleted: allCompleted,
        );
      }
    });

    taskStatusPerDay = newStatusMap.asObservable();
  }

  @action
  void updateTasksStatus(Set<String> tasksIds, {required bool newStatus}) {
    final List<Task> tempList = List<Task>.from(monthlyTasks);

    for (var taskId in tasksIds) {
      final index = tempList.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        final oldTask = tempList[index];
        final updatedTask = oldTask.copyWith(completed: newStatus);
        tempList[index] = updatedTask;
      }
    }

    monthlyTasks = tempList.asObservable();

    _calculateTaskStatusForMonth();
  }
}

class DayTaskStatus {
  final bool tasksExist;
  final bool allTasksCompleted;

  DayTaskStatus({this.tasksExist = false, this.allTasksCompleted = false});
}
