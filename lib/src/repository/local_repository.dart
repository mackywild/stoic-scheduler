import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity.dart';
import '../models/execution_record.dart';

class LocalRepository {
  static const _activitiesKey = 'stoic_activities_v1';
  static const _recordsKey = 'stoic_records_v1';

  late SharedPreferences _preferences;

  List<Activity> activities = [];
  List<ExecutionRecord> records = [];

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();

    final activityJson = _preferences.getString(_activitiesKey);
    final recordJson = _preferences.getString(_recordsKey);

    if (activityJson == null) {
      activities = _defaultActivities();
      await _saveActivities();
    } else {
      final decoded = jsonDecode(activityJson) as List<dynamic>;
      activities = decoded
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (recordJson == null) {
      records = [];
    } else {
      final decoded = jsonDecode(recordJson) as List<dynamic>;
      records = decoded
          .map((e) => ExecutionRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> upsertActivity(Activity activity) async {
    final index = activities.indexWhere((e) => e.id == activity.id);
    if (index >= 0) {
      activities[index] = activity;
    } else {
      activities.add(activity);
    }
    await _saveActivities();
  }

  Future<void> deleteActivity(String id) async {
    activities.removeWhere((e) => e.id == id);
    await _saveActivities();
  }

  Future<void> addRecord(ExecutionRecord record) async {
    records.insert(0, record);
    await _saveRecords();
  }

  Future<void> resetAll() async {
    activities = _defaultActivities();
    records = [];
    await _saveActivities();
    await _saveRecords();
  }

  Future<void> _saveActivities() async {
    await _preferences.setString(
      _activitiesKey,
      jsonEncode(activities.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _saveRecords() async {
    await _preferences.setString(
      _recordsKey,
      jsonEncode(records.map((e) => e.toJson()).toList()),
    );
  }

  List<Activity> _defaultActivities() => [
        Activity(
          id: 'study',
          name: '資格勉強',
          priority: 5,
          dailyTargetMinutes: 60,
          minimumMinutes: 15,
          maximumMinutes: 60,
          contexts: [
            StoicContext.commute,
            StoicContext.afterMeal,
            StoicContext.home,
          ],
        ),
        Activity(
          id: 'reading',
          name: '読書',
          priority: 4,
          dailyTargetMinutes: 30,
          minimumMinutes: 10,
          maximumMinutes: 45,
          contexts: StoicContext.values,
        ),
        Activity(
          id: 'game',
          name: 'ゲーム',
          priority: 2,
          dailyTargetMinutes: 60,
          minimumMinutes: 15,
          maximumMinutes: 60,
          contexts: [StoicContext.home],
        ),
        Activity(
          id: 'workout',
          name: '筋トレ',
          priority: 4,
          dailyTargetMinutes: 20,
          minimumMinutes: 15,
          maximumMinutes: 30,
          contexts: [StoicContext.home],
        ),
      ];
}
