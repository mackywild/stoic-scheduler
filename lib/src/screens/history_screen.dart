import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../models/execution_record.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.records,
    required this.activities,
  });

  final List<ExecutionRecord> records;
  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '履歴',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        if (records.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('まだ実行履歴がありません。最初の指令を完遂してください。'),
            ),
          ),
        for (final record in records) ...[
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(
                  record.result == ExecutionResult.completed
                      ? Icons.check
                      : Icons.close,
                ),
              ),
              title: Text(record.activityName),
              subtitle: Text(
                '${_format(record.startedAt)}  •  ${record.context.label}\n'
                '${record.result == ExecutionResult.completed ? '完了 ${record.actualMinutes}分' : 'SKIP：${record.skipReason ?? '理由なし'}'}',
              ),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  String _format(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}/${two(value.month)}/${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}
