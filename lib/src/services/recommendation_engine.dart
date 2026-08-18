import '../models/activity.dart';
import '../models/execution_record.dart';
import '../models/recommendation.dart';

class RecommendationEngine {
  Recommendation? recommend({
    required List<Activity> activities,
    required List<ExecutionRecord> records,
    required StoicContext context,
    required int availableMinutes,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();

    final candidates = activities.where((activity) {
      return activity.enabled &&
          activity.contexts.contains(context) &&
          activity.minimumMinutes <= availableMinutes;
    }).toList();

    if (candidates.isEmpty) return null;

    Recommendation? best;

    for (final activity in candidates) {
      final completedToday = _completedToday(
        activity.id,
        records,
        clock,
      );

      final remaining = (activity.dailyTargetMinutes - completedToday)
          .clamp(0, activity.dailyTargetMinutes);

      final remainingRatio = activity.dailyTargetMinutes == 0
          ? 0.0
          : remaining / activity.dailyTargetMinutes;

      final successRate = _learnedSuccessRate(
        activityId: activity.id,
        records: records,
        context: context,
        hour: clock.hour,
      );

      final recommendedMinutes = [
        availableMinutes,
        activity.maximumMinutes,
        remaining == 0 ? activity.minimumMinutes : remaining,
      ].reduce((a, b) => a < b ? a : b).clamp(
            activity.minimumMinutes,
            activity.maximumMinutes,
          );

      double score = 0;
      score += activity.priority * 20;
      score += remainingRatio * 35;
      score += successRate * 25;
      score += 10; // context fit: candidate filtering済み
      score += _timeFit(activity, availableMinutes);

      if (remaining == 0) {
        score -= 35;
      }

      final reasonParts = <String>[
        '優先度 ${activity.priority}/5',
        remaining > 0 ? '本日の残り目標 $remaining分' : '本日の目標達成済み',
      ];

      final sampleCount = _learningSampleCount(
        activityId: activity.id,
        records: records,
        context: context,
        hour: clock.hour,
      );

      if (sampleCount >= 3) {
        reasonParts.add(
          'この時間帯・状況での実行率 ${(successRate * 100).round()}%',
        );
      } else {
        reasonParts.add('学習データ収集中');
      }

      final recommendation = Recommendation(
        activity: activity,
        minutes: recommendedMinutes,
        score: score,
        reason: reasonParts.join(' / '),
      );

      if (best == null || recommendation.score > best.score) {
        best = recommendation;
      }
    }

    return best;
  }

  int _completedToday(
    String activityId,
    List<ExecutionRecord> records,
    DateTime now,
  ) {
    return records
        .where((record) =>
            record.activityId == activityId &&
            record.result == ExecutionResult.completed &&
            _sameDate(record.startedAt, now))
        .fold(0, (sum, record) => sum + record.actualMinutes);
  }

  double _learnedSuccessRate({
    required String activityId,
    required List<ExecutionRecord> records,
    required StoicContext context,
    required int hour,
  }) {
    final matches = _learningMatches(
      activityId: activityId,
      records: records,
      context: context,
      hour: hour,
    );

    if (matches.length < 3) return 0.5;

    final completed =
        matches.where((e) => e.result == ExecutionResult.completed).length;

    // Laplace smoothing
    return (completed + 1) / (matches.length + 2);
  }

  int _learningSampleCount({
    required String activityId,
    required List<ExecutionRecord> records,
    required StoicContext context,
    required int hour,
  }) {
    return _learningMatches(
      activityId: activityId,
      records: records,
      context: context,
      hour: hour,
    ).length;
  }

  List<ExecutionRecord> _learningMatches({
    required String activityId,
    required List<ExecutionRecord> records,
    required StoicContext context,
    required int hour,
  }) {
    final bucket = _timeBucket(hour);

    return records.where((record) {
      return record.activityId == activityId &&
          record.context == context &&
          _timeBucket(record.startedAt.hour) == bucket;
    }).toList();
  }

  int _timeBucket(int hour) {
    if (hour < 6) return 0;
    if (hour < 10) return 1;
    if (hour < 13) return 2;
    if (hour < 17) return 3;
    if (hour < 21) return 4;
    return 5;
  }

  double _timeFit(Activity activity, int availableMinutes) {
    if (availableMinutes >= activity.minimumMinutes &&
        availableMinutes <= activity.maximumMinutes) {
      return 10;
    }
    if (availableMinutes > activity.maximumMinutes) {
      return 6;
    }
    return 0;
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
