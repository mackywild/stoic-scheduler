import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../models/execution_record.dart';
import '../models/recommendation.dart';
import '../repository/local_repository.dart';
import '../services/recommendation_engine.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.activities,
    required this.records,
    required this.onChanged,
  });

  final LocalRepository repository;
  final List<Activity> activities;
  final List<ExecutionRecord> records;
  final VoidCallback onChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecommendationEngine _engine = RecommendationEngine();

  StoicContext _context = StoicContext.commute;
  double _availableMinutes = 30;
  Recommendation? _recommendation;
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recalculate());
  }

  void _recalculate() {
    setState(() {
      _recommendation = _engine.recommend(
        activities: widget.activities,
        records: widget.records,
        context: _context,
        availableMinutes: _availableMinutes.round(),
      );
      _startedAt = null;
    });
  }

  Future<void> _complete() async {
    final recommendation = _recommendation;
    if (recommendation == null) return;

    final actual = await _askActualMinutes(recommendation.minutes);
    if (actual == null) return;

    await widget.repository.addRecord(
      ExecutionRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        activityId: recommendation.activity.id,
        activityName: recommendation.activity.name,
        context: _context,
        startedAt: _startedAt ?? DateTime.now(),
        plannedMinutes: recommendation.minutes,
        actualMinutes: actual,
        result: ExecutionResult.completed,
      ),
    );

    widget.onChanged();
    _recalculate();
  }

  Future<void> _skip() async {
    final recommendation = _recommendation;
    if (recommendation == null) return;

    final reason = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('なぜスキップしますか？'),
              subtitle: Text('この回答も次回の推薦精度に使います。'),
            ),
            for (final reason in const [
              '疲れている',
              '時間がない',
              '場所が悪い',
              '気分じゃない',
              '別の予定が入った',
            ])
              ListTile(
                title: Text(reason),
                onTap: () => Navigator.pop(context, reason),
              ),
          ],
        ),
      ),
    );

    if (reason == null) return;

    await widget.repository.addRecord(
      ExecutionRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        activityId: recommendation.activity.id,
        activityName: recommendation.activity.name,
        context: _context,
        startedAt: _startedAt ?? DateTime.now(),
        plannedMinutes: recommendation.minutes,
        result: ExecutionResult.skipped,
        skipReason: reason,
      ),
    );

    widget.onChanged();
    _recalculate();
  }

  Future<int?> _askActualMinutes(int initial) {
    int value = initial;
    return showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('完了'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('実際に何分取り組みましたか？'),
              const SizedBox(height: 12),
              Text(
                '$value 分',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Slider(
                value: value.toDouble(),
                min: 1,
                max: 120,
                divisions: 119,
                label: '$value分',
                onChanged: (v) => setDialogState(() => value = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, value),
              child: const Text('記録'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendation = _recommendation;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'STOIC SCHEDULER',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          '考えるな。今やることだけ決めてもらえ。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<StoicContext>(
          initialValue: _context,
          decoration: const InputDecoration(
            labelText: '現在の状況',
            border: OutlineInputBorder(),
          ),
          items: StoicContext.values
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.label),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            _context = value;
            _recalculate();
          },
        ),
        const SizedBox(height: 20),
        Text('空き時間：${_availableMinutes.round()}分'),
        Slider(
          value: _availableMinutes,
          min: 5,
          max: 120,
          divisions: 23,
          label: '${_availableMinutes.round()}分',
          onChanged: (value) {
            setState(() => _availableMinutes = value);
          },
          onChangeEnd: (_) => _recalculate(),
        ),
        const SizedBox(height: 16),
        if (recommendation == null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.hourglass_empty, size: 44),
                  const SizedBox(height: 12),
                  const Text('今の条件で実行できる行動がありません。'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('行動画面で条件を追加してください'),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    "TODAY'S ORDER",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Icon(
                    _startedAt == null ? Icons.bolt : Icons.timer,
                    size: 54,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recommendation.activity.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${recommendation.minutes} MINUTES',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    recommendation.reason,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  if (_startedAt == null)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => setState(() => _startedAt = DateTime.now()),
                        icon: const Icon(Icons.play_arrow),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('START'),
                        ),
                      ),
                    )
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _complete,
                        icon: const Icon(Icons.check),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('COMPLETE'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _skip,
                        child: const Text('SKIP'),
                      ),
                    ),
                  ],
                  if (_startedAt == null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _skip,
                      child: const Text('別のことをする'),
                    ),
                  ]
                ],
              ),
            ),
          ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _recalculate,
          icon: const Icon(Icons.refresh),
          label: const Text('再判定'),
        ),
      ],
    );
  }
}
