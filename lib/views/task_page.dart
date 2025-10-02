import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:meu_tempo/config/application_constants.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/enums/notification.dart';
import 'package:meu_tempo/enums/repeat_frequency.dart';
import 'package:meu_tempo/enums/task_priority.dart';
import 'package:meu_tempo/locator/locator.dart';
import 'package:meu_tempo/models/task.dart';
import 'package:meu_tempo/models/users.dart';
import 'package:meu_tempo/models/time_center.dart';
import 'package:meu_tempo/repositories/task_repository.dart';
import 'package:meu_tempo/repositories/time_center_repository.dart';
import 'package:meu_tempo/services/couchbase_service.dart';
import 'package:meu_tempo/services/task_notification_service.dart';
import 'package:meu_tempo/services/users_service.dart';
import 'package:meu_tempo/services/util_service.dart';
import 'package:meu_tempo/services/validation_mixin.dart';
import 'package:meu_tempo/store/task_store.dart';
import 'package:meu_tempo/views/home_page.dart';
import 'package:meu_tempo/widgets/custom_alert.dart';
import 'package:meu_tempo/widgets/custom_appBar.dart';
import 'package:meu_tempo/widgets/custom_button.dart';
import 'package:meu_tempo/widgets/custom_date_picker.dart';
import 'package:meu_tempo/widgets/custom_dropdown.dart';
import 'package:meu_tempo/widgets/custom_input.dart';
import 'package:meu_tempo/widgets/custom_shielded_task.dart';
import 'package:meu_tempo/widgets/timer_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with ValidationsMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String? _selectCenter;

  final CouchbaseService couchbaseService = CouchbaseService();
  late final TaskRepository taskRepository;
  late final usersService = UsersService();
  Users? _currentUser;
  late final timeCenterRepository;
  final TaskStore taskStore = getIt<TaskStore>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _centerController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  final TextEditingController _observationController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _notificationController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _recurrenceController = TextEditingController();

  bool _isAllDay = false;
  final int _maxLength = 300;
  bool _isSelected = false;

  Future<void> _loadUser() async {
    final user = await usersService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _submit() async {
    try {
      if (_formKey.currentState?.saveAndValidate() ?? false) {
        if (!UtilService.isEndTimeAfterStartTime(
            _startTimeController.text, _endTimeController.text)) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlert(
                title: 'Horário inválido',
                message: 'A hora final deve ser posterior à hora inicial.',
                type: AlertType.warning,
                onOkPressed: () => Navigator.of(context).pop(),
              );
            },
          );
          return;
        }

        TimeCenter? selectedTimeCenter = timeCenterList?.firstWhere(
          (center) => center.name == _selectCenter,
        );

        var task = Task(
          id: Uuid().v4(),
          title: _titleController.text,
          timeCenters: selectedTimeCenter!,
          date: _dataController.text,
          startTime: _startTimeController.text,
          endTime: _endTimeController.text,
          priority: TaskPriority.fromString(_priorityController.text) ??
              TaskPriority.SIMPLE,
          repeatFrequency:
              RepeatFrequency.fromString(_recurrenceController.text),
          notification:
              NotificationEnum.fromString(_notificationController.text) ??
                  NotificationEnum.NO_NOTIFICATION,
          shieldedTask: _isSelected,
          observation: _observationController.text,
          userId: _currentUser!.id!,
        );

        final isShieldedTask =
            await taskStore.taskRepository.hasShieldTaskAtDateTime(
          userId: _currentUser!.id!,
          date: _dataController.text,
          startTime: _startTimeController.text,
          endTime: _endTimeController.text,
        );

        if (isShieldedTask == true) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlert(
                title: 'Horário Blindado!',
                message:
                    'Já existe uma tarefa blindada cadastrada nesse horário',
                type: AlertType.warning,
                onOkPressed: () => Navigator.pop(context),
              );
            },
          );

          return;
        }

        await taskStore.addTask(task);
        await TaskNotificationService().scheduleTaskNotification(task);

        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlert(
                title: 'Sucesso',
                message: 'Tarefa cadastrada com sucesso!',
                type: AlertType.success,
                onOkPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (route) => false),
              );
            });
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlert(
              title: 'Erro',
              message: 'Erro ao cadastrar tarefa: $e',
              type: AlertType.error,
              onOkPressed: () {},
            );
          });
    }
  }

  void _listen(String label) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          debugPrint('Status: $val');
          if (val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) {
          debugPrint('Error: $val');
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);
        String _lastFinalResult = '';

        _speech.listen(
          onResult: (val) {
            debugPrint(
                'Resultado: ${val.recognizedWords} (final: ${val.finalResult})');
            if (val.recognizedWords.isNotEmpty) {
              setState(() {
                if (val.finalResult) {
                  String newText = val.recognizedWords.trim();
                  if (!_lastFinalResult.endsWith(newText)) {
                    if (label == 'title') {
                      _titleController.text = _titleController.text.isNotEmpty
                          ? '${_titleController.text} $newText'
                          : newText;
                    } else if (label == 'observation') {
                      String updatedText =
                          _observationController.text.isNotEmpty
                              ? '${_observationController.text} $newText'
                              : newText;

                      if (updatedText.length <= _maxLength) {
                        _observationController.text = updatedText;
                      } else {
                        _observationController.text =
                            updatedText.substring(0, _maxLength);
                      }
                    }
                  }
                  _lastFinalResult = newText;
                }
              });
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.dictation,
            partialResults: true,
          ),
          localeId: 'pt_BR',
          cancelOnError: true,
        );
      }
    } else {
      _speech.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser().then((_) {
      if (_currentUser != null) {
        _loadTimeCenters();
      }
    });
    _speech = stt.SpeechToText();
    _setCurrentDate();
    _setCurrentTime();
    _setEndTime30Minutes();

    taskRepository = TaskRepository(couchbaseService: couchbaseService);
    timeCenterRepository =
        TimeCenterRepository(couchbaseService: couchbaseService);

    couchbaseService.startReplication(
        collectionName: ApplicationConstants.collectionTasks, onSynced: () {});
  }

  List<TimeCenter>? timeCenterList;

  Future<void> _loadTimeCenters() async {
    if (_currentUser != null) {
      try {
        final result = await timeCenterRepository.fetchIdUser(_currentUser!.id);
        if (mounted) {
          setState(() {
            timeCenterList = result;
          });
        }
      } catch (e) {
        setState(() {
          timeCenterList = [];
        });
      }
    }
  }

  void _setCurrentDate() {
    final now = DateTime.now();
    _dataController.text = '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
  }

  void _setCurrentTime() {
    final now = DateTime.now();
    _startTimeController.text = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  void _setEndTime30Minutes() {
    final now = DateTime.now();
    final endTime = now.add(const Duration(minutes: 30));
    _endTimeController.text = '${endTime.hour.toString().padLeft(2, '0')}:'
        '${endTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Adicionar Tarefa',
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: FormBuilder(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  bottom: MediaQuery.of(context).size.height * 0.03,
                  left: MediaQuery.of(context).size.width * 0.04,
                  right: MediaQuery.of(context).size.width * 0.04,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomInput(
                            label: 'Titulo',
                            colorBorder: MainColor.primaryColor,
                            colorLabel: MainColor.primaryColor,
                            colorText: MainColor.primaryColor,
                            colorError: Colors.red,
                            controller: _titleController,
                            keyboardType: TextInputType.text,
                            fieldName: 'title',
                            validator: (val) =>
                                isNotEmpty(val, 'O titulo é obrigatório'),
                            onChanged: (val) {
                              if (val != null && val.isNotEmpty) {
                                _formKey.currentState?.fields['title']
                                    ?.validate();
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 24),
                          child: IconButton(
                            onPressed: () {
                              _listen('title');
                            },
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_off,
                              color: MainColor.primaryColor,
                            ),
                            tooltip: 'Falar',
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: CustomDropdown<TimeCenter>(
                        label: 'Centro de Tempo',
                        option: timeCenterList ?? [],
                        controller: _centerController,
                        colorLabel: MainColor.primaryColor,
                        colorBorder: MainColor.primaryColor,
                        itemAsString: (center) => center.name,
                        fieldName: 'center',
                        validator: (TimeCenter? val) {
                          if (val == null) {
                            return 'Centro de tempo é obrigatório';
                          }

                          return null;
                        },
                        onChanged: (val) {
                          setState(() {
                            _selectCenter = val?.name;
                            _formKey.currentState?.fields['center']?.validate();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: CustomDropdown<TaskPriority>(
                        label: 'Prioridade',
                        option: TaskPriority.values,
                        controller: _priorityController,
                        colorLabel: MainColor.primaryColor,
                        colorBorder: MainColor.primaryColor,
                        itemAsString: (priority) => priority.label,
                        validator: (val) =>
                            isNotEmpty(val?.label, 'Prioridade é obrigatório'),
                        fieldName: 'priority',
                        onChanged: (val) {
                          _formKey.currentState?.fields['priority']?.validate();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: CustomDropdown<NotificationEnum>(
                        label: 'Notificação',
                        option: NotificationEnum.values,
                        controller: _notificationController,
                        colorBorder: MainColor.primaryColor,
                        colorLabel: MainColor.primaryColor,
                        itemAsString: (notification) => notification.message,
                        validator: (val) => isNotEmpty(
                            val?.message, 'Notificação é obrigatório'),
                        fieldName: 'notification',
                        onChanged: (val) {
                          _formKey.currentState?.fields['notification']
                              ?.validate();
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDatePicker(
                            label: 'Data',
                            controller: _dataController,
                            colorBorder: MainColor.primaryColor,
                            colorLabel: MainColor.primaryColor,
                            iconColor: MainColor.primaryColor,
                            validator: (val) =>
                                isNotEmpty(val, 'A data é obrigatório'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: CustomShieldedTask(
                            isSelected: _isSelected,
                            onToggle: () {
                              setState(() {
                                _isSelected = !_isSelected;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TimePicker(
                          startTimeController: _startTimeController,
                          endTimeController: _endTimeController,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                              Transform.translate(
                                offset: Offset(0, 10),
                                child: Text(
                                  'Dia Todo',
                                  style: TextStyle(
                                      color: MainColor.primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Checkbox(
                                value: _isAllDay,
                                onChanged: (bool? val) {
                                  setState(() {
                                    _isAllDay = val ?? false;
                                    if (_isAllDay) {
                                      _startTimeController.text = "08:00";
                                      _endTimeController.text = "18:00";
                                    } else {
                                      _setCurrentTime();
                                      _setEndTime30Minutes();
                                    }
                                  });
                                },
                                activeColor: MainColor.primaryColor,
                                side: BorderSide(
                                  color: MainColor.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CustomDropdown<RepeatFrequency>(
                        label: 'Recorrência',
                        option: RepeatFrequency.values,
                        controller: _recurrenceController,
                        colorLabel: MainColor.primaryColor,
                        colorBorder: MainColor.primaryColor,
                        itemAsString: (frequency) => frequency.message,
                        validator: (val) => isNotEmpty(
                            val?.message, 'Recorrência é obrigatório'),
                        fieldName: 'recurrence',
                        onChanged: (val) {
                          _formKey.currentState?.fields['recurrence']
                              ?.validate();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: CustomInput(
                                  label: 'Observação',
                                  colorBorder: MainColor.primaryColor,
                                  colorLabel: MainColor.primaryColor,
                                  colorText: MainColor.primaryColor,
                                  colorError: Colors.red,
                                  controller: _observationController,
                                  maxLength: _maxLength,
                                  keyboardType: TextInputType.text,
                                  fieldName: 'observation',
                                  onChanged: (val) {
                                    if (val != null && val.isNotEmpty) {
                                      _formKey
                                          .currentState?.fields['observation']
                                          ?.validate();
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () => _listen('observation'),
                                icon: Icon(
                                  _isListening ? Icons.mic : Icons.mic_off,
                                  color: MainColor.primaryColor,
                                ),
                                tooltip: 'Falar',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 40, left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: CustomButton(
                                text: 'Limpar',
                                onPressed: () {
                                  _formKey.currentState?.reset();
                                  _titleController.clear();
                                  _dataController.clear();
                                  _observationController.clear();
                                  _setCurrentDate();
                                  _setCurrentTime();
                                  _setEndTime30Minutes();
                                  setState(() {
                                    _isAllDay = false;
                                    _isSelected = false;
                                  });
                                },
                                color: Colors.white,
                                textColor: MainColor.primaryColor,
                                borderColor: MainColor.primaryColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: CustomButton(
                                text: 'Cadastrar',
                                onPressed: () {
                                  _submit();
                                },
                                color: MainColor.primaryColor,
                                textColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
