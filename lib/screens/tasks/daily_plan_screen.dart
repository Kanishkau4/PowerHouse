import 'package:flutter/material.dart';

import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/services/daily_tasks_service.dart';
import 'package:powerhouse/widgets/animated_message.dart';
import 'package:powerhouse/widgets/tasks/plan_stats_widget.dart';
import 'package:powerhouse/widgets/tasks/task_item_card.dart';

class DailyPlanScreen extends StatefulWidget {
  const DailyPlanScreen({super.key});

  @override
  State<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends State<DailyPlanScreen> {
  final _dailyTasksService = DailyTasksService();

  List<Map<String, dynamic>> dailyTasks = [];
  bool _isLoading = true;

  // Stats
  int completedTasks = 0;
  int totalTasks = 0;
  int remainingMinutes = 0;
  int totalCalories = 0;

  int currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _dailyTasksService.getTodayTasks();
      final streak = await _dailyTasksService.getCurrentStreak();

      _calculateStats(tasks);
      setState(() {
        dailyTasks = tasks;
        currentStreak = streak;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() => _isLoading = false);
    }
  }

  void _calculateStats(List<Map<String, dynamic>> tasks) {
    int completed = 0;
    int minutes = 0;
    int calories = 0;

    for (var task in tasks) {
      final isCompleted = task['is_completed'] as bool? ?? false;
      if (isCompleted) {
        completed++;
      } else {
        // Only count remaining minutes
        minutes += (task['duration'] as int? ?? 0);
      }
      // Count total calories for the day (regardless of completion?)
      // Usually calories are "goals" to burn, so maybe total planned calories.
      calories += (task['calories'] as int? ?? 0);
    }

    setState(() {
      completedTasks = completed;
      totalTasks = tasks.length;
      remainingMinutes = minutes;
      totalCalories = calories;
    });
  }

  Future<void> _toggleTaskCompletion(String taskId, bool currentStatus) async {
    // Find index
    final index = dailyTasks.indexWhere((t) => t['task_id'] == taskId);
    if (index == -1) return;

    // Optimistic Update
    final originalTask = Map<String, dynamic>.from(dailyTasks[index]);

    setState(() {
      dailyTasks[index]['is_completed'] = !currentStatus;
      _calculateStats(dailyTasks); // Recalculate stats immediately
    });

    try {
      if (!currentStatus) {
        await _dailyTasksService.completeTask(taskId);
        // Show XP message
        if (mounted) {
          AnimatedMessage.show(
            context,
            message: '+5 XP earned!',
            backgroundColor: const Color(0xFF1DAB87),
            icon: Icons.star,
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        await _dailyTasksService.uncompleteTask(taskId);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        dailyTasks[index] = originalTask;
        _calculateStats(dailyTasks);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to update task')));
      }
    }
  }

  Future<void> _addNewTask() async {
    // Logic to add new task dialog
    // For now, minimal placeholder or simple dialog
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground,
        title: Text(
          'Add New Task',
          style: TextStyle(color: context.primaryText),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: context.primaryText),
          decoration: InputDecoration(
            hintText: 'e.g., Drink water',
            hintStyle: TextStyle(color: context.secondaryText),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.dividerColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _dailyTasksService.addCustomTask(title: controller.text);
                if (mounted) {
                  Navigator.pop(context);
                  _loadTasks(); // Reload to show new task
                }
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Color(0xFF1DAB87)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group tasks
    print('DEBUG: DailyPlanScreen build. Streak: $currentStreak');
    final todoTasks = dailyTasks
        .where((t) => (t['is_completed'] as bool? ?? false) == false)
        .toList();
    final completedList = dailyTasks
        .where((t) => (t['is_completed'] as bool? ?? false) == true)
        .toList();

    return Scaffold(
      backgroundColor: context.surfaceColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        backgroundColor: const Color(0xFF1DAB87),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: context.surfaceColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.primaryText),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF844B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF844B), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '⚡ $currentStreak Streak',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF844B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              title: Text(
                "Today's Plan",
                style: TextStyle(
                  color: context.primaryText,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
            pinned: true,
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  PlanStatsWidget(
                    completedTasks: completedTasks,
                    totalTasks: totalTasks,
                    remainingMinutes: remainingMinutes,
                    totalCalories: totalCalories,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF1DAB87)),
              ),
            )
          else ...[
            // To Do Section Header
            if (todoTasks.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Text(
                    'To Do (${todoTasks.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.primaryText,
                    ),
                  ),
                ),
              ),

            // To Do List
            if (todoTasks.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = todoTasks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 6,
                    ),
                    child: TaskItemCard(
                      task: task,
                      onTap: () {},
                      onToggle: (val) =>
                          _toggleTaskCompletion(task['task_id'], false),
                    ),
                  );
                }, childCount: todoTasks.length),
              ),

            // Completed Section Header
            if (completedList.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text(
                    'Completed (${completedList.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color:
                          context.secondaryText, // Dimmer for completed header
                    ),
                  ),
                ),
              ),

            // Completed List
            if (completedList.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = completedList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 6,
                    ),
                    child: TaskItemCard(
                      task: task,
                      onTap: () {},
                      onToggle: (val) =>
                          _toggleTaskCompletion(task['task_id'], true),
                    ),
                  );
                }, childCount: completedList.length),
              ),

            // Bottom Padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
    );
  }
}
