import 'package:flutter_test/flutter_test.dart';
import 'package:stoic_scheduler/src/models/activity.dart';
import 'package:stoic_scheduler/src/models/execution_record.dart';
import 'package:stoic_scheduler/src/services/recommendation_engine.dart';

void main() {
  final engine = RecommendationEngine();

  test('現在の状況で実行できない行動は推薦しない', () {
    final activities = [
      Activity(
        id: 'workout',
        name: '筋トレ',
        priority: 5,
        dailyTargetMinutes: 30,
        minimumMinutes: 10,
        maximumMinutes: 30,
        contexts: [StoicContext.home],
      ),
      Activity(
        id: 'read',
        name: '読書',
        priority: 3,
        dailyTargetMinutes: 30,
        minimumMinutes: 10,
        maximumMinutes: 30,
        contexts: [StoicContext.commute],
      ),
    ];

    final result = engine.recommend(
      activities: activities,
      records: [],
      context: StoicContext.commute,
      availableMinutes: 30,
      now: DateTime(2026, 8, 17, 8),
    );

    expect(result?.activity.id, 'read');
  });

  test('空き時間より最低実施時間が長い行動は除外される', () {
    final activities = [
      Activity(
        id: 'study',
        name: '勉強',
        priority: 5,
        dailyTargetMinutes: 60,
        minimumMinutes: 20,
        maximumMinutes: 60,
        contexts: [StoicContext.commute],
      ),
    ];

    final result = engine.recommend(
      activities: activities,
      records: [],
      context: StoicContext.commute,
      availableMinutes: 10,
      now: DateTime(2026, 8, 17, 8),
    );

    expect(result, isNull);
  });

  test('同条件で成功履歴が多い行動は推薦スコアが上がる', () {
    final study = Activity(
      id: 'study',
      name: '勉強',
      priority: 3,
      dailyTargetMinutes: 60,
      minimumMinutes: 10,
      maximumMinutes: 30,
      contexts: [StoicContext.commute],
    );
    final read = Activity(
      id: 'read',
      name: '読書',
      priority: 3,
      dailyTargetMinutes: 60,
      minimumMinutes: 10,
      maximumMinutes: 30,
      contexts: [StoicContext.commute],
    );

    final records = <ExecutionRecord>[
      for (int i = 1; i <= 5; i++)
        ExecutionRecord(
          id: 's$i',
          activityId: 'study',
          activityName: '勉強',
          context: StoicContext.commute,
          startedAt: DateTime(2026, 8, 10 + i, 8),
          plannedMinutes: 20,
          actualMinutes: 20,
          result: ExecutionResult.completed,
        ),
      for (int i = 1; i <= 5; i++)
        ExecutionRecord(
          id: 'r$i',
          activityId: 'read',
          activityName: '読書',
          context: StoicContext.commute,
          startedAt: DateTime(2026, 8, 10 + i, 8),
          plannedMinutes: 20,
          result: ExecutionResult.skipped,
          skipReason: '気分じゃない',
        ),
    ];

    final result = engine.recommend(
      activities: [study, read],
      records: records,
      context: StoicContext.commute,
      availableMinutes: 30,
      now: DateTime(2026, 8, 17, 8),
    );

    expect(result?.activity.id, 'study');
  });
}
