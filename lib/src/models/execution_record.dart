import 'activity.dart';

enum ExecutionResult { completed, skipped }

class ExecutionRecord {
  ExecutionRecord({
    required this.id,
    required this.activityId,
    required this.activityName,
    required this.context,
    required this.startedAt,
    required this.plannedMinutes,
    required this.result,
    this.actualMinutes = 0,
    this.skipReason,
  });

  final String id;
  final String activityId;
  final String activityName;
  final StoicContext context;
  final DateTime startedAt;
  final int plannedMinutes;
  final ExecutionResult result;
  final int actualMinutes;
  final String? skipReason;

  Map<String, dynamic> toJson() => {
        'id': id,
        'activityId': activityId,
        'activityName': activityName,
        'context': context.name,
        'startedAt': startedAt.toIso8601String(),
        'plannedMinutes': plannedMinutes,
        'result': result.name,
        'actualMinutes': actualMinutes,
        'skipReason': skipReason,
      };

  factory ExecutionRecord.fromJson(Map<String, dynamic> json) {
    return ExecutionRecord(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      activityName: json['activityName'] as String? ?? '不明',
      context: StoicContext.values.byName(json['context'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
      plannedMinutes: json['plannedMinutes'] as int,
      result: ExecutionResult.values.byName(json['result'] as String),
      actualMinutes: json['actualMinutes'] as int? ?? 0,
      skipReason: json['skipReason'] as String?,
    );
  }
}
