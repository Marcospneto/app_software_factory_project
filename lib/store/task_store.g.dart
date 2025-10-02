// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TaskStore on _TaskStore, Store {
  late final _$monthlyTasksAtom =
      Atom(name: '_TaskStore.monthlyTasks', context: context);

  @override
  ObservableList<Task> get monthlyTasks {
    _$monthlyTasksAtom.reportRead();
    return super.monthlyTasks;
  }

  @override
  set monthlyTasks(ObservableList<Task> value) {
    _$monthlyTasksAtom.reportWrite(value, super.monthlyTasks, () {
      super.monthlyTasks = value;
    });
  }

  late final _$taskStatusPerDayAtom =
      Atom(name: '_TaskStore.taskStatusPerDay', context: context);

  @override
  ObservableMap<String, DayTaskStatus> get taskStatusPerDay {
    _$taskStatusPerDayAtom.reportRead();
    return super.taskStatusPerDay;
  }

  @override
  set taskStatusPerDay(ObservableMap<String, DayTaskStatus> value) {
    _$taskStatusPerDayAtom.reportWrite(value, super.taskStatusPerDay, () {
      super.taskStatusPerDay = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_TaskStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$fetchTaskAsyncAction =
      AsyncAction('_TaskStore.fetchTask', context: context);

  @override
  Future<void> fetchTask(String date) {
    return _$fetchTaskAsyncAction.run(() => super.fetchTask(date));
  }

  late final _$fetchTasksByMonthAsyncAction =
      AsyncAction('_TaskStore.fetchTasksByMonth', context: context);

  @override
  Future<void> fetchTasksByMonth(DateTime date) {
    return _$fetchTasksByMonthAsyncAction
        .run(() => super.fetchTasksByMonth(date));
  }

  late final _$addTaskAsyncAction =
      AsyncAction('_TaskStore.addTask', context: context);

  @override
  Future<void> addTask(Task task) {
    return _$addTaskAsyncAction.run(() => super.addTask(task));
  }

  late final _$_TaskStoreActionController =
      ActionController(name: '_TaskStore', context: context);

  @override
  void _calculateTaskStatusForMonth() {
    final _$actionInfo = _$_TaskStoreActionController.startAction(
        name: '_TaskStore._calculateTaskStatusForMonth');
    try {
      return super._calculateTaskStatusForMonth();
    } finally {
      _$_TaskStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateTasksStatus(Set<String> tasksIds, {required bool newStatus}) {
    final _$actionInfo = _$_TaskStoreActionController.startAction(
        name: '_TaskStore.updateTasksStatus');
    try {
      return super.updateTasksStatus(tasksIds, newStatus: newStatus);
    } finally {
      _$_TaskStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
monthlyTasks: ${monthlyTasks},
taskStatusPerDay: ${taskStatusPerDay},
isLoading: ${isLoading}
    ''';
  }
}
