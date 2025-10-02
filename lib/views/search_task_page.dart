import 'package:flutter/material.dart';
import 'package:meu_tempo/config/application_constants.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/models/task.dart';
import 'package:meu_tempo/models/users.dart';
import 'package:meu_tempo/repositories/task_repository.dart';
import 'package:meu_tempo/services/couchbase_service.dart';
import 'package:meu_tempo/services/users_service.dart';
import 'package:meu_tempo/widgets/custom_appBar.dart';
import 'package:meu_tempo/widgets/custom_button.dart';
import 'package:meu_tempo/widgets/custom_floating_button.dart';
import 'package:meu_tempo/widgets/custom_modal_filter.dart';
import 'package:meu_tempo/widgets/custom_task_result_card.dart';

class SearchTaskPage extends StatefulWidget {
  const SearchTaskPage({super.key});

  @override
  State<SearchTaskPage> createState() => _SearchTaskPageState();
}

class _SearchTaskPageState extends State<SearchTaskPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearched = false;
  bool _hasSelectedCards = false;
  Map<String, dynamic> currentFilters = {};

  final CouchbaseService couchbaseService = CouchbaseService();
  late final TaskRepository taskRepository;
  late final usersService = UsersService();
  Users? _currentUser;
  late final timeCenterRepository;

  List<Task> _tasksResults = [];
  Set<String> _selectedTasksIds = {};

  Future<void> _performSearch([Map<String, dynamic>? filters]) async {
    final query = _searchController.text.trim();
    setState(() {
      currentFilters = filters ?? currentFilters;
    });

    final hasTextQuery = query.isNotEmpty;
    final hasActiveFilters =
        currentFilters.values.any((value) => value != null);

    List<Task> tasks;

    if (hasTextQuery) {
      tasks = await taskRepository.searchTasksByTitle(query, _currentUser!.id!);
    } else if (hasActiveFilters) {
      if (currentFilters['date'] == 'Personalizado') {
        tasks = await taskRepository.searchTasks(
          userId: _currentUser!.id!,
          priority: currentFilters['priority'],
          timeCenter: currentFilters['timeCenter'],
          dateFilter: currentFilters['date'],
          startDate: currentFilters['startDate'],
          endDate: currentFilters['endDate'],
        );
      } else {
        tasks = await taskRepository.searchTasks(
          userId: _currentUser!.id!,
          priority: currentFilters['priority'],
          timeCenter: currentFilters['timeCenter'],
          dateFilter: currentFilters['date'],
        );
      }
    } else {
      tasks = [];
    }

    setState(() {
      _tasksResults = tasks;
      _hasSearched = true;
      _selectedTasksIds.clear();
      _updateSelectionState();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedTasksIds.clear();
      _hasSelectedCards = false;
    });
  }

  void _updateSelectionState() {
    setState(() {
      _hasSelectedCards = _selectedTasksIds.isNotEmpty;
    });
  }

  void _onCardSelectionChanged(int index, bool isSelected) {
    setState(() {
      final taskId = _tasksResults[index].id!;
      if (isSelected) {
        _selectedTasksIds.add(taskId);
      } else {
        _selectedTasksIds.remove(taskId);
      }

      _hasSelectedCards = _selectedTasksIds.isNotEmpty;
    });
  }

  void _onTasksModified() {
    _clearSelection();
    _performSearch();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return CustomModalFilter(
          onCancel: () => Navigator.pop(context),
          onApply: (filters) {
            _performSearch(filters);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await usersService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    taskRepository = TaskRepository(couchbaseService: couchbaseService);
    couchbaseService.startReplication(
        collectionName: ApplicationConstants.collectionTasks, onSynced: () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pesquisar',
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0, top: 30.0),
            child: TextButton(
              onPressed: _showFilterModal,
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.transparent;
                    }
                    if (states.contains(WidgetState.focused)) {
                      return Colors.transparent;
                    }
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.transparent;
                    }
                    return null;
                  },
                ),
                minimumSize: WidgetStateProperty.all(Size.zero),
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined,
                    size: 24,
                    color: MainColor.primaryColor,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    'Filtrar',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: MainColor.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 16.0, right: 20.0),
            child: TextFormField(
              controller: _searchController,
              readOnly: _hasSearched,
              decoration: InputDecoration(
                hintText: _hasSearched ? '' : 'Pesquisar',
                hintStyle: TextStyle(color: MainColor.primaryColor),
                suffixIcon: _hasSearched
                    ? IconButton(
                        icon: Icon(Icons.close, color: MainColor.primaryColor),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _hasSearched = false;
                            _tasksResults = [];
                            currentFilters = {};
                          });
                        },
                      )
                    : Icon(Icons.search, color: MainColor.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: MainColor.primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide:
                      BorderSide(color: MainColor.primaryColor, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide:
                      BorderSide(color: MainColor.primaryColor, width: 1.0),
                ),
                contentPadding:
                    const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
              ),
              style: TextStyle(color: MainColor.primaryColor),
              onFieldSubmitted: (text) {
                _performSearch();
              },
            ),
          ),
          if (!_hasSearched)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20.0, top: 40.0),
              child: CustomButton(
                text: 'Pesquisar',
                onPressed: () {
                  _performSearch(currentFilters);
                },
                color: MainColor.primaryColor,
              ),
            ),
          if (_hasSearched)
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, top: 40.0, right: 20.0),
                child: _tasksResults.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          'Não há resultados',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: MainColor.primaryColor,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Todos os resultados',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: MainColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.49,
                            child: ListView.builder(
                              itemCount: _tasksResults.length,
                              itemBuilder: (context, index) {
                                final item = _tasksResults[index];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: CustomTaskResultCard(
                                    title: item.title,
                                    date: item.date,
                                    startTime: item.startTime,
                                    endTime: item.endTime,
                                    borderColor: item.completed == true
                                        ? Colors.grey.shade400
                                        : item.priority!.color,
                                    cardColor: item.completed == true
                                        ? Colors.grey.shade400
                                        : item.timeCenters.color,
                                    onSelectionChanged: (isSelected) {
                                      _onCardSelectionChanged(index, isSelected);
                                    },
                                    isSelected: _selectedTasksIds.contains(item.id),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
        ],
      ),
      floatingActionButton: _hasSelectedCards
          ? CustomFloatingButton(
              selectedTaskIds: _selectedTasksIds,
              onTasksModified: _onTasksModified,
            )
          : null,
    );
  }
}
