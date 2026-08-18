import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../repository/local_repository.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({
    super.key,
    required this.repository,
    required this.activities,
    required this.onChanged,
  });

  final LocalRepository repository;
  final List<Activity> activities;
  final VoidCallback onChanged;

  Future<void> _edit(
    BuildContext context, {
    Activity? activity,
  }) async {
    final nameController = TextEditingController(text: activity?.name ?? '');
    int priority = activity?.priority ?? 3;
    int target = activity?.dailyTargetMinutes ?? 30;
    int minimum = activity?.minimumMinutes ?? 10;
    int maximum = activity?.maximumMinutes ?? 60;
    final contexts = <StoicContext>{
      ...(activity?.contexts ?? StoicContext.values),
    };

    final result = await showDialog<Activity>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(activity == null ? '行動を追加' : '行動を編集'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '行動名'),
                  ),
                  const SizedBox(height: 16),
                  _numberRow(
                    context,
                    label: '優先度',
                    value: priority,
                    min: 1,
                    max: 5,
                    onChanged: (v) => setState(() => priority = v),
                  ),
                  _numberRow(
                    context,
                    label: '1日の目標',
                    value: target,
                    min: 0,
                    max: 180,
                    suffix: '分',
                    onChanged: (v) => setState(() => target = v),
                  ),
                  _numberRow(
                    context,
                    label: '最低実施',
                    value: minimum,
                    min: 5,
                    max: 60,
                    suffix: '分',
                    onChanged: (v) {
                      setState(() {
                        minimum = v;
                        if (maximum < minimum) maximum = minimum;
                      });
                    },
                  ),
                  _numberRow(
                    context,
                    label: '最大実施',
                    value: maximum,
                    min: minimum,
                    max: 180,
                    suffix: '分',
                    onChanged: (v) => setState(() => maximum = v),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 12, bottom: 6),
                      child: Text('実行可能な状況'),
                    ),
                  ),
                  for (final item in StoicContext.values)
                    CheckboxListTile(
                      value: contexts.contains(item),
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.label),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            contexts.add(item);
                          } else {
                            contexts.remove(item);
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: nameController.text.trim().isEmpty || contexts.isEmpty
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        Activity(
                          id: activity?.id ??
                              DateTime.now().microsecondsSinceEpoch.toString(),
                          name: nameController.text.trim(),
                          priority: priority,
                          dailyTargetMinutes: target,
                          minimumMinutes: minimum,
                          maximumMinutes: maximum,
                          contexts: contexts.toList(),
                          enabled: activity?.enabled ?? true,
                        ),
                      );
                    },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();

    if (result != null) {
      await repository.upsertActivity(result);
      onChanged();
    }
  }

  static Widget _numberRow(
    BuildContext context, {
    required String label,
    required int value,
    required int min,
    required int max,
    String suffix = '',
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 60,
          child: Text(
            '$value$suffix',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '行動',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            FilledButton.icon(
              onPressed: () => _edit(context),
              icon: const Icon(Icons.add),
              label: const Text('追加'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (final activity in activities) ...[
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              title: Text(
                activity.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '優先度 ${activity.priority}/5  •  '
                  '目標 ${activity.dailyTargetMinutes}分  •  '
                  '${activity.minimumMinutes}〜${activity.maximumMinutes}分\n'
                  '${activity.contexts.map((e) => e.label).join(' / ')}',
                ),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await _edit(context, activity: activity);
                  }
                  if (value == 'toggle') {
                    await repository.upsertActivity(
                      activity.copyWith(enabled: !activity.enabled),
                    );
                    onChanged();
                  }
                  if (value == 'delete') {
                    await repository.deleteActivity(activity.id);
                    onChanged();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('編集')),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(activity.enabled ? '無効化' : '有効化'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('削除')),
                ],
              ),
              enabled: activity.enabled,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
