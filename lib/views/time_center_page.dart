import 'package:flutter/material.dart';
import 'package:meu_tempo/config/application_constants.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/models/task.dart';
import 'package:meu_tempo/models/time_center.dart';
import 'package:meu_tempo/repositories/task_repository.dart';
import 'package:meu_tempo/repositories/time_center_repository.dart';
import 'package:meu_tempo/services/couchbase_service.dart';
import 'package:meu_tempo/services/users_service.dart';
import 'package:meu_tempo/widgets/custom_alert.dart';
import 'package:meu_tempo/widgets/custom_appbar.dart';
import 'package:meu_tempo/widgets/custom_loading.dart';
import 'package:meu_tempo/widgets/custom_snackbar.dart';
import 'package:uuid/uuid.dart';

class TimeCenterPage extends StatefulWidget {
  @override
  _TimeCenterPageState createState() => _TimeCenterPageState();
}

class _TimeCenterPageState extends State<TimeCenterPage> {
  final TextEditingController _newValueController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _editingIndex;
  List<TextEditingController> _editingControllers = [];
  List<TimeCenter> timeCenters = [];
  final couchbaseService = CouchbaseService();
  late final TimeCenterRepository repository;
  final UsersService usersService = UsersService();
  Color _newTimeCenterColor = Colors.purple;
  bool _isLoading = true;
  late final TaskRepository taskRepository;
  List<Task>? _listTask;

  @override
  void initState() {
    super.initState();
    initApp();
    taskRepository = TaskRepository(couchbaseService: couchbaseService);
  }

  Future<void> initApp() async {
    setState(() {
      _isLoading = true;
    });

    repository = TimeCenterRepository(couchbaseService: couchbaseService);
    await _loadTimeCenters();

    couchbaseService.startReplication(
      collectionName: ApplicationConstants.collectionTimeCenters,
      onSynced: () {
        _loadTimeCenters();
      },
    );
    couchbaseService.networkStatusListen();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadTimeCenters() async {
    try {
      final userId = await _getIdUser();
      if (userId != null) {
        final centers = await repository.fetchIdUser(userId);

        centers.sort((a, b) => a.order.compareTo(b.order));
        setState(() {
          _disposeEditingControllers();
          timeCenters = centers;
          _editingControllers = timeCenters
              .map((center) => TextEditingController(text: center.name))
              .toList();
        });
      }
    } catch (e) {
      CustomSnackbar(
        context,
        message: 'Erro ao carregar centros de tempo: $e',
        type: SnackBarType.error,
        timeSeconds: 3,
      );
    }
  }

  void _disposeEditingControllers() {
    for (final controller in _editingControllers) {
      controller.dispose();
    }
    _editingControllers = [];
  }

  bool _isColorAlreadyUsed(Color color) {
    return timeCenters.any((tc) => tc.color.value == color.value);
  }

  void _selectColor(int index) async {
    final currentColor = timeCenters[index].color;
    final newColor = await showDialog<Color>(
      context: context,
      builder: (context) => _ColorPickerDialog(
        currentColor: currentColor,
        timeCenters:
            timeCenters.where((tc) => tc.id != timeCenters[index].id).toList(),
      ),
    );

    if (newColor != null && newColor != currentColor) {
      try {
        final updatedTimeCenter = timeCenters[index].copyWith(color: newColor);
        await repository.addItem(updatedTimeCenter);

        setState(() {
          timeCenters[index] = updatedTimeCenter;
        });

        CustomSnackbar(
          context,
          message: 'Cor atualizada com sucesso!',
          type: SnackBarType.success,
          timeSeconds: 2,
        );
      } catch (e) {
        CustomSnackbar(
          context,
          message: 'Erro ao atualizar a cor: $e',
          type: SnackBarType.error,
          timeSeconds: 3,
        );
      }
    }
  }

  Future<void> _saveTimeCenter() async {
    final colorValues = timeCenters.map((tc) => tc.color.value).toList();
    final hasDuplicates = colorValues.length != colorValues.toSet().length;

    if (hasDuplicates) {
      CustomSnackbar(
        context,
        message: 'Existem centros de tempo com cores repetidas',
        type: SnackBarType.error,
        timeSeconds: 3,
      );
      return;
    }

    try {
      final uniqueTimeCenters = {
        for (var tc in timeCenters) tc.name.toLowerCase(): tc
      }.values.toList();

      for (final timeCenter in uniqueTimeCenters) {
        await repository.addItem(timeCenter);
      }

      CustomSnackbar(
        context,
        message: 'Todos os centros de tempo foram salvos com sucesso!',
        type: SnackBarType.success,
        timeSeconds: 3,
      );
    } catch (e) {
      CustomSnackbar(
        context,
        message: 'Erro ao salvar os centros de tempo: $e',
        type: SnackBarType.error,
        timeSeconds: 3,
      );
      rethrow;
    }
  }

  void _startEditing(int index) {
    setState(() {
      _editingIndex = index;
      while (_editingControllers.length <= index) {
        _editingControllers.add(TextEditingController());
      }
      _editingControllers[index].text = timeCenters[index].name;
    });
  }

  void _removeItem(int index) async {
    final timeCenterToDelete = timeCenters[index];

    final hasTasks = await taskRepository.hasTasksWithTimeCenter(timeCenterToDelete.name);

    if (hasTasks) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlert(
            title: 'Warning',
            message: 'Você não pode excluir este centro de tempo porque ele está vinculado a tarefas. Por favor, remova as tarefas relacionadas antes de continuar.',
            type: AlertType.warning,
            onOkPressed: () => Navigator.pop(context),
          );
        },
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text(
            'Tem certeza que deseja remover "${timeCenterToDelete.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (timeCenterToDelete.id != null) {
          await repository.deleteItem(timeCenterToDelete.id!);
        } else {
          throw Exception('TimeCenter ID is null');
        }
        setState(() {
          _editingControllers[index].dispose();
          _editingControllers.removeAt(index);
          timeCenters.removeAt(index);

          for (int i = 0; i < timeCenters.length; i++) {
            timeCenters[i] = timeCenters[i].copyWith(order: i);
          }
        });
      } catch (e) {
        CustomSnackbar(
          context,
          message: 'Erro ao remover item: $e',
          type: SnackBarType.error,
          timeSeconds: 3,
        );
      }
    }
  }

  TimeCenter? _saveEditing(int index) {
    final newText = _editingControllers[index].text.trim();
    if (newText.isNotEmpty) {
      final updatedTimeCenter = timeCenters[index].copyWith(name: newText);
      setState(() {
        timeCenters[index] = updatedTimeCenter;
        _editingIndex = null;
      });
      return updatedTimeCenter;
    }
    return null;
  }

  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
    });
  }

  Future<void> _addNewValue() async {
    if (timeCenters.length >= 20) {
      CustomSnackbar(
        context,
        message: 'Limite máximo de 20 centros de tempo atingido',
        type: SnackBarType.alert,
        timeSeconds: 3,
      );
      return;
    }

    final textTimeCenter = _newValueController.text.trim();

    if (textTimeCenter.isEmpty) {
      CustomSnackbar(
        context,
        message: 'Digite um nome para o centro de tempo',
        type: SnackBarType.alert,
        timeSeconds: 3,
      );
      return;
    }

    if (timeCenters
        .any((tc) => tc.name.toLowerCase() == textTimeCenter.toLowerCase())) {
      CustomSnackbar(
        context,
        message: 'Este valor já foi adicionado.',
        type: SnackBarType.alert,
        timeSeconds: 3,
      );
      return;
    }

    if (_isColorAlreadyUsed(_newTimeCenterColor)) {
      CustomSnackbar(
        context,
        message: 'Esta cor já está sendo usada por outro centro de tempo',
        type: SnackBarType.alert,
        timeSeconds: 3,
      );
      return;
    }

    final idUser = await _getIdUser();
    final newTimeCenter = TimeCenter(
        id: const Uuid().v4(),
        name: textTimeCenter,
        color: _newTimeCenterColor,
        order: timeCenters.length,
        idUser: idUser ?? '');

    try {
      await repository.addItem(newTimeCenter);
      setState(() {
        timeCenters.add(newTimeCenter);
        _editingControllers.add(TextEditingController(text: textTimeCenter));
        _newValueController.clear();
        _newTimeCenterColor = MainColor.secondaryColor;
      });
      CustomSnackbar(
        context,
        message: 'Centro de tempo adicionado com sucesso!',
        type: SnackBarType.success,
        timeSeconds: 2,
      );
    } catch (e) {
      CustomSnackbar(
        context,
        message: 'Erro ao adicionar centro de tempo: $e',
        type: SnackBarType.error,
        timeSeconds: 3,
      );
    }
  }

  Future<String?> _getIdUser() async {
    final user = await usersService.getCurrentUser();
    if (user != null) {
      return user.id;
    }
    return null;
  }

  @override
  void dispose() {
    _newValueController.dispose();
    _scrollController.dispose();
    _disposeEditingControllers();
    couchbaseService.networkConnection?.cancel();
    couchbaseService.replicator?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Centro de tempo',
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CustomLoadingWidget(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '↑ Maior Importância',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MainColor.primaryColor,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: ReorderableListView.builder(
                    onReorder: (oldIndex, newIndex) async {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;

                        final item = timeCenters.removeAt(oldIndex);
                        timeCenters.insert(newIndex, item);

                        final controller =
                            _editingControllers.removeAt(oldIndex);
                        _editingControllers.insert(newIndex, controller);

                        // Atualiza a ordem localmente
                        for (int i = 0; i < timeCenters.length; i++) {
                          timeCenters[i] = timeCenters[i].copyWith(order: i);
                        }
                      });

                      try {
                        // Salva a nova ordem no banco
                        await repository.updateTimeCenterOrder(timeCenters);

                        CustomSnackbar(
                          context,
                          message: 'Nova ordem salva com sucesso!',
                          type: SnackBarType.success,
                          timeSeconds: 2,
                        );
                      } catch (e) {
                        CustomSnackbar(
                          context,
                          message: 'Erro ao salvar nova ordem: $e',
                          type: SnackBarType.error,
                          timeSeconds: 3,
                        );
                      }
                    },
                    itemCount: timeCenters.length,
                    itemBuilder: (context, index) {
                      final timeCenter = timeCenters[index];
                      final isEditing = _editingIndex == index;

                      return Container(
                        key: ValueKey(timeCenter.id),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 13),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: MainColor.primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.drag_handle,
                                color: MainColor.primaryColor, size: 25),
                            SizedBox(width: 10),
                            Expanded(
                              child: isEditing
                                  ? TextField(
                                      controller: _editingControllers[index],
                                      decoration: InputDecoration(
                                          border: InputBorder.none),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: MainColor.primaryColor,
                                      ),
                                      autofocus: true,
                                      onSubmitted: (_) => _saveEditing(index),
                                    )
                                  : Text(
                                      timeCenter.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: MainColor.primaryColor,
                                      ),
                                    ),
                            ),
                            if (isEditing)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check_circle,
                                        color: Colors.green, size: 20),
                                    onPressed: () async {
                                      final updatedTimeCenter =
                                          _saveEditing(index);
                                      if (updatedTimeCenter != null) {
                                        try {
                                          await repository.addItem(
                                              updatedTimeCenter); // Atualiza no banco de dados
                                          CustomSnackbar(
                                            context,
                                            message:
                                                'Centro de tempo atualizado com sucesso!',
                                            type: SnackBarType.success,
                                            timeSeconds: 2,
                                          );
                                        } catch (e) {
                                          CustomSnackbar(
                                            context,
                                            message: 'Erro ao atualizar: $e',
                                            type: SnackBarType.error,
                                            timeSeconds: 3,
                                          );
                                        }
                                      } else {
                                        CustomSnackbar(
                                          context,
                                          message:
                                              'O nome não pode estar vazio',
                                          type: SnackBarType.alert,
                                          timeSeconds: 2,
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.red, size: 20),
                                    onPressed: () => _removeItem(index),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward,
                                        color: Colors.black87, size: 20),
                                    onPressed: _cancelEditing,
                                  ),
                                ],
                              )
                            else
                              IconButton(
                                icon: Icon(Icons.edit,
                                    color: MainColor.primaryColor, size: 20),
                                onPressed: () => _startEditing(index),
                              ),
                            if (!isEditing)
                              IconButton(
                                icon: Icon(Icons.palette,
                                    color: timeCenter.color, size: 20),
                                onPressed: () => _selectColor(index),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '↓ Menor Importância',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MainColor.primaryColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newValueController,
                          decoration: InputDecoration(
                            hintText: 'Novo valor (${timeCenters.length}/20)',
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: MainColor.primaryColor),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: MainColor.primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            enabled: timeCenters.length < 20,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.palette,
                                  color: _newTimeCenterColor),
                              onPressed: () async {
                                final newColor = await showDialog<Color>(
                                  context: context,
                                  builder: (context) => _ColorPickerDialog(
                                    currentColor: _newTimeCenterColor,
                                    timeCenters: timeCenters,
                                  ),
                                );
                                if (newColor != null) {
                                  setState(() {
                                    _newTimeCenterColor = newColor;
                                  });
                                }
                              },
                            ),
                          ),
                          onSubmitted: (_) => _addNewValue(),
                        ),
                      ),
                      SizedBox(width: 8),
                      InkWell(
                        onTap: _addNewValue,
                        child: Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: MainColor.primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(Icons.expand_less, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 6)
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.palette, color: Colors.grey),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Quer mudar a cor do seu Centro de Tempo?\n'
                            '  ● Toque no ícone igual a esse ao lado. \n' 
                            '  ● Vai aparecer uma caixinha com várias \n' 
                            '     cores, escolha a sua favorita.',
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 48)
              ],
            ),
    );
  }
}

class _ColorPickerDialog extends StatelessWidget {
  final Color currentColor;
  final List<TimeCenter> timeCenters;

  const _ColorPickerDialog({
    required this.currentColor,
    required this.timeCenters,
  });

  bool _isColorUsed(Color color) {
    return timeCenters.any((tc) => tc.color.value == color.value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          'Escolha uma cor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: ApplicationConstants.availableColors.map((color) {
              final isUsed = _isColorUsed(color);
              return GestureDetector(
                onTap: isUsed ? null : () => Navigator.of(context).pop(color),
                child: Opacity(
                  opacity: isUsed ? 0.5 : 1.0,
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: 20,
                    child: color == currentColor
                        ? Icon(Icons.check, color: Colors.white)
                        : isUsed
                            ? Icon(Icons.block, color: Colors.white)
                            : null,
                  ),
                ),
              );
            }).toList(),
          ),
          if (ApplicationConstants.availableColors
              .any((color) => _isColorUsed(color)))
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Cores em uso estão desabilitadas',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
