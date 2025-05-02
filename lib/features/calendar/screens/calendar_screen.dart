import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:taskify/features/tasks/provider/task_provider.dart';
import 'package:taskify/features/tasks/models/task.dart';
import 'package:taskify/features/tasks/widgets/tasks_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now(); // Día actualmente enfocado
  DateTime? _selectedDay = DateTime.now(); // Día seleccionado

  // Mapa para rastrear el estado de expansión de las tareas
  final Map<String, bool> _expandedTasks = {};

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    // Función para cargar las tareas de un día específico
    List<Task> _getTasksForDay(DateTime day) {
      return taskProvider.tasks.where((task) {
        return task.date.year == day.year &&
            task.date.month == day.month &&
            task.date.day == day.day;
      }).toList();
    }

    final tasksForSelectedDay = _getTasksForDay(_selectedDay!);

    void _toggleTaskExpansion(String taskId) {
      setState(() {
        _expandedTasks[taskId] = !(_expandedTasks[taskId] ?? false);
      });
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TableCalendar<Task>(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                // Mostrar puntos solo si el día no está seleccionado
                if (isSameDay(day, _selectedDay)) {
                  return [];
                }
                return _getTasksForDay(day);
              },
              calendarStyle: CalendarStyle(
                todayTextStyle: const TextStyle(
                  color:
                      AppColors
                          .roseBonbon, // Cambiar el color del texto del día actual
                  fontWeight: FontWeight.bold,
                ),
                todayDecoration:
                    const BoxDecoration(), // Sin decoración para el día actual
                selectedDecoration: BoxDecoration(
                  color: AppColors.argentinianBlue,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(color: AppColors.skyMagenta),
                defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
                outsideTextStyle: const TextStyle(color: AppColors.textHint),
                disabledTextStyle: const TextStyle(color: AppColors.textHint),
                holidayTextStyle: const TextStyle(
                  color: AppColors.lavenderFloral,
                ),
                markerDecoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3, // Máximo de puntos por día
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.argentinianBlue,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.argentinianBlue,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: const TextStyle(color: AppColors.textSecondary),
                weekendStyle: const TextStyle(color: AppColors.skyMagenta),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final task = tasksForSelectedDay[index];
              return TasksWidget(
                task: task,
                categoryColor: Colors.blue, // Puedes personalizar el color
                isExpanded: _expandedTasks[task.id] ?? false,
                onExpansionChanged: () => _toggleTaskExpansion(task.id),
                onTaskUpdated: () {
                  setState(() {});
                },
                onTap: () {
                  // Acción al tocar la tarea
                },
              );
            }, childCount: tasksForSelectedDay.length),
          ),
        ],
      ),
    );
  }
}
