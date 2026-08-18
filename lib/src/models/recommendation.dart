import 'activity.dart';

class Recommendation {
  const Recommendation({
    required this.activity,
    required this.minutes,
    required this.score,
    required this.reason,
  });

  final Activity activity;
  final int minutes;
  final double score;
  final String reason;
}
