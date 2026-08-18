import 'package:flutter/material.dart';

import '../models/execution_record.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.records});

  final List<ExecutionRecord> records;

  @override
  Widget build(BuildContext context) {
    final completed =
        records.where((e) => e.result == ExecutionResult.completed).length;
    final skipped =
        records.where((e) => e.result == ExecutionResult.skipped).length;
    final total = records.length;
    final rate = total == 0 ? 0.0 : completed / total;
    final score = (rate * 100).round();
    final minutes = records
        .where((e) => e.result == ExecutionResult.completed)
        .fold(0, (sum, e) => sum + e.actualMinutes);
    final streak = _streakDays(records);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'STOIC SCORE',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              children: [
                Text(
                  '$score',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: rate),
                const SizedBox(height: 10),
                Text('指令達成率 ${(rate * 100).toStringAsFixed(1)}%'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'COMPLETE',
                value: '$completed',
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'SKIP',
                value: '$skipped',
                icon: Icons.cancel_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'TOTAL MIN',
                value: '$minutes',
                icon: Icons.timer_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'STREAK',
                value: '$streak日',
                icon: Icons.local_fire_department_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          '判定ロジック',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          '優先度・今日の未達量・現在の状況・空き時間・'
          '同じ時間帯と状況での過去成功率から次の指令を決めます。',
        ),
      ],
    );
  }

  int _streakDays(List<ExecutionRecord> records) {
    final dates = records
        .where((e) => e.result == ExecutionResult.completed)
        .map((e) => DateTime(
              e.startedAt.year,
              e.startedAt.month,
              e.startedAt.day,
            ))
        .toSet();

    if (dates.isEmpty) return 0;

    var day = DateTime.now();
    day = DateTime(day.year, day.month, day.day);

    if (!dates.contains(day)) {
      day = day.subtract(const Duration(days: 1));
    }

    int streak = 0;
    while (dates.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
