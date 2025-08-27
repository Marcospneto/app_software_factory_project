import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:meu_tempo/config/application_constants.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/models/users.dart';
import 'package:meu_tempo/repositories/task_repository.dart';
import 'package:meu_tempo/services/couchbase_service.dart';
import 'package:meu_tempo/services/users_service.dart';
import 'package:meu_tempo/widgets/custom_alert.dart';
import 'package:meu_tempo/widgets/custom_date_picker.dart';

class CustomFloatingButton extends StatefulWidget {
  final Set<String> selectedTaskIds;
  final VoidCallback? onTasksModified;

  const CustomFloatingButton({
    super.key,
    required this.selectedTaskIds,
    this.onTasksModified,
  });

  @override
  State<CustomFloatingButton> createState() => _CustomFloatingButtonState();
}

class _CustomFloatingButtonState extends State<CustomFloatingButton> {
  final CouchbaseService couchbaseService = CouchbaseService();
  late final TaskRepository taskRepository;
  late final usersService = UsersService();
  Users? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
    taskRepository = TaskRepository(couchbaseService: couchbaseService);
    couchbaseService.startReplication(
      collectionName: ApplicationConstants.collectionTasks,
      onSynced: () {},
    );
  }

  Future<void> _loadUser() async {
    final user = await usersService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _completedTasks(Set<String> tasksIds) async {
    final success = await taskRepository.completeMultipleTasks(tasksIds);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => CustomAlert(
        title: success ? 'Sucesso' : 'Erro',
        message: success
            ? 'Tarefas concluídas com sucesso!'
            : 'Erro ao concluir algumas tarefas.',
        type: success ? AlertType.success : AlertType.error,
        onOkPressed: () {
          Navigator.of(context).pop();
          if (success && widget.onTasksModified != null) {
            widget.onTasksModified!();
          }
        },
      ),
    );
  }


  Future<void> _reactivateTask(Set<String> tasksIds) async {
    final success = await taskRepository.reactivateTask(tasksIds);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => CustomAlert(
        title: success ? 'Sucesso' : 'Erro',
        message: success
            ? 'Tarefas reativadas com sucesso!'
            : 'Erro ao reativar algumas tarefas.',
        type: success ? AlertType.success : AlertType.error,
        onOkPressed: () {
          Navigator.of(context).pop();
          if (success && widget.onTasksModified != null) {
            widget.onTasksModified!();
          }
        },
      ),
    );
  }

  Future<void> _moveTask(Set<String> tasksIds, String date) async {
    final success = await taskRepository.moveTask(tasksIds, date);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => CustomAlert(
          title: success ? 'Sucesso' : 'Erro',
          message: success
              ? 'Tarefa movida para uma nova data'
              : 'Não foi possível mover para outra data',
          type: success ? AlertType.success : AlertType.error,
        onOkPressed: () {
          Navigator.of(context).pop();
          if (success && widget.onTasksModified != null) {
            widget.onTasksModified!();
          }
        },
      ),
    );
  }

  Future<void> _checkTasksCompleted(
    Set<String> tasksIds, {
    required String action,
  }) async {
    final tasks = await taskRepository.getTasksByIds(tasksIds);

    final invalidTasks = <String>[];

    if (action == "complete") {
      for (final task in tasks) {
        if (task.completed == true) {
          invalidTasks.add(task.title);
        }
      }

      if (invalidTasks.isNotEmpty) {
        if (invalidTasks.length == 1) {
          _showErrorDialog(
            "Não foi possível concluir a tarefa \'${invalidTasks.join(', ')}\' pois já está concluída."
          );
          return;
        } else if (invalidTasks.length > 1) {
          _showErrorDialog(
            "Não foi possível concluir as tarefas \'${invalidTasks.join(', ')}\' pois já estão concluídas. Desmarque-as e tente novamente."
          );
          return;
        }
      }
      
      await _completedTasks(tasksIds);
    
    } else if (action == "reactivate") {
      for (final task in tasks) {
        if (task.completed == false) {
          invalidTasks.add(task.title);
        }
      }

      if (invalidTasks.isNotEmpty) {
        if (invalidTasks.length == 1) {
          _showErrorDialog(
            "Não foi possível reativar a tarefa \'${invalidTasks.join(', ')}\', pois já está concluída."
          );
          return;
        } else if (invalidTasks.length > 1) {
          _showErrorDialog(
            "Não foi possível reativar as tarefas \'${invalidTasks.join(', ')}\', pois já estão concluídas. Desmarque-as e tente novamente."
          );
          return;
        }
      }
      
      await _reactivateTask(tasksIds);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => CustomAlert(
        title: 'Atenção',
        message: message,
        type: AlertType.warning,
        onOkPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.more_vert,
      activeIcon: Icons.close,
      foregroundColor: Colors.white,
      activeForegroundColor: Colors.white,
      backgroundColor: MainColor.secondaryColor,
      overlayColor: Colors.black54,
      overlayOpacity: 0.4,
      spacing: 12,
      spaceBetweenChildren: 8,
      children: [
        SpeedDialChild(
          child: Icon(Icons.calendar_today, color: Colors.white),
          backgroundColor: MainColor.secondaryColor,
          label: 'Mover Tarefa',
          labelStyle: TextStyle(fontSize: 14),
          onTap: () async {
            final TextEditingController dateController = TextEditingController();

            await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Selecionar nova data'),
                content: CustomDatePicker(
                  label: 'Nova Data',
                  controller: dateController,
                  colorBorder: MainColor.primaryColor,
                  iconColor: MainColor.primaryColor,
                  colorLabel: MainColor.primaryColor,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (dateController.text.isNotEmpty) {
                        _moveTask(widget.selectedTaskIds, dateController.text);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Mover'),
                  ),
                ],
              ),
            );
          },

        ),
        SpeedDialChild(
          child: Icon(Icons.check, color: Colors.white),
          backgroundColor: MainColor.secondaryColor,
          label: 'Concluir Tarefa',
          labelStyle: TextStyle(fontSize: 14),
          onTap: () => _checkTasksCompleted(widget.selectedTaskIds, action: "complete"),
        ),
        SpeedDialChild(
          child: Icon(Icons.lock_open, color: Colors.white),
          backgroundColor: MainColor.secondaryColor,
          label: 'Reativar Tarefa',
          labelStyle: TextStyle(fontSize: 14),
          onTap: () => _checkTasksCompleted(widget.selectedTaskIds, action: "reactivate"),
        ),
      ],
    );
  }
}

