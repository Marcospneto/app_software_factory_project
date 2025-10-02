import 'package:flutter/material.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/models/task.dart';
import 'package:meu_tempo/widgets/custom_task_result_card.dart';

class TimelineIndicator extends StatelessWidget {
  final String hour;
  final List<Task> tasks;
  final Set<String> selectedTaskIds;
  final Function(String, bool) onSelectionChanged;

  const TimelineIndicator({
    Key? key,
    required this.hour,
    required this.tasks,
    required this.selectedTaskIds,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: MainColor.primaryColor,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              hour,
              style: TextStyle(
                  fontSize: 14,
                  color: MainColor.primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
              child: tasks.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, bottom: 8.0, right: 8.0, left: 8.0),
                          child: SizedBox(
                            width: 300,
                            child: CustomTaskResultCard(
                              title: task.title,
                              date: task.date,
                              startTime: task.startTime,
                              endTime: task.endTime,
                              borderColor: task.completed == true
                                  ? Colors.grey.shade400
                                  : task.priority!.color,
                              cardColor: task.completed == true
                                  ? Colors.grey.shade400
                                  : task.timeCenters.color,
                              isSelected: selectedTaskIds.contains(task.id),
                              onSelectionChanged: (isSelected) {
                                onSelectionChanged(task.id!, isSelected);
                              },
                            ),
                          ),
                        );
                      },
                    )),
        ],
      ),
    );
  }
}
