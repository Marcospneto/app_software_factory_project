import 'package:flutter/material.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/enums/task_priority.dart';
import 'package:meu_tempo/models/time_center.dart';
import 'package:meu_tempo/models/users.dart';
import 'package:meu_tempo/repositories/time_center_repository.dart';
import 'package:meu_tempo/services/couchbase_service.dart';
import 'package:meu_tempo/services/users_service.dart';
import 'package:meu_tempo/widgets/custom_date_range_bottom_sheet.dart';

import 'custom_button.dart';

class CustomModalFilter extends StatefulWidget {
  final Function() onCancel;
  final Function(Map<String, dynamic> filters) onApply;
  final Function(String)? onSearchChanged;

  const CustomModalFilter({
    super.key,
    required this.onCancel,
    required this.onApply,
    this.onSearchChanged,
  });

  @override
  State<CustomModalFilter> createState() => _CustomModalFilterState();
}

class _CustomModalFilterState extends State<CustomModalFilter> {
  late final couchbaseService;
  late final TimeCenterRepository timeCenterRepository;
  late final UsersService usersService = UsersService();

  Users? _currentUser;
  List<TimeCenter>? timeCenterList;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? selectedPriority;
  String? selectedTimeCenter;
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    couchbaseService = CouchbaseService();
    timeCenterRepository =
        TimeCenterRepository(couchbaseService: couchbaseService);
    _loadUser().then((_) {
      if (_currentUser != null) {
        _loadTimeCenters();
      }
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _showCustomDateRangePicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return CustomDateRangeBottomSheet(
          startDateController: _startDateController,
          endDateController: _endDateController,
          onConfirm: (start, end) {
            setState(() {
              _startDate = start;
              _endDate = end;
              selectedDate = 'Personalizado';
            });
          },
        );
      },
    );
  }

  Future<void> _loadUser() async {
    final user = await usersService.getCurrentUser();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  Future<void> _loadTimeCenters() async {
    if (_currentUser != null) {
      try {
        final result =
            await timeCenterRepository.fetchIdUser(_currentUser!.id!);
        if (mounted) {
          setState(() => timeCenterList = result);
        }
      } catch (e) {
        if (mounted) {
          setState(() => timeCenterList = []);
        }
        debugPrint('Erro ao carregar centros de tempo: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (timeCenterList == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const Text(
            'Filtrar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    title: 'PRIORIDADE',
                    items: TaskPriority.values.map((e) => e.label).toList(),
                    selectedValue: selectedPriority,
                    onSelected: (value) =>
                        setState(() => selectedPriority = value),
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    title: 'CENTRO DE TEMPO',
                    items: timeCenterList!.map((tc) => tc.name).toList(),
                    selectedValue: selectedTimeCenter,
                    onSelected: (value) =>
                        setState(() => selectedTimeCenter = value),
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    title: 'DATA DA TAREFA',
                    items: const [
                      'Hoje',
                      'Ontem',
                      'Esta semana',
                      'Este mês',
                      'Personalizado'
                    ],
                    selectedValue: selectedDate,
                    onSelected: (value) {
                      setState(() {
                        selectedDate = value;
                        _startDate = null;
                        _endDate = null;
                        _startDateController.clear();
                        _endDateController.clear();
                      });

                      if (value == 'Personalizado') {
                        _showCustomDateRangePicker(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    widget.onApply({
                      'priority': selectedPriority,
                      'timeCenter': selectedTimeCenter,
                      'date': selectedDate,
                      'startDate': _startDate,
                      'endDate': _endDate,
                    });
                  },
                  color: MainColor.primaryColor,
                  text: 'Aplicar',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<dynamic> items,
    required String? selectedValue,
    required Function(String?) onSelected,
    bool isTimeCenter = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final displayText =
                  item is TimeCenter ? item.name : item as String;
              final value = item is TimeCenter ? item.id : item;
              final isSelected = selectedValue == value;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(displayText),
                  selected: isSelected,
                  onSelected: (selected) => onSelected(selected ? value : null),
                  selectedColor: MainColor.primaryColor,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  showCheckmark: false,
                  avatar: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.white,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
