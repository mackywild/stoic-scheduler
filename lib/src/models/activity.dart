enum StoicContext {
  commute('通勤'),
  afterMeal('食後'),
  home('自宅'),
  outside('外出');

  const StoicContext(this.label);
  final String label;
}

class Activity {
  Activity({
    required this.id,
    required this.name,
    required this.priority,
    required this.dailyTargetMinutes,
    required this.minimumMinutes,
    required this.maximumMinutes,
    required this.contexts,
    this.enabled = true,
  });

  final String id;
  final String name;
  final int priority;
  final int dailyTargetMinutes;
  final int minimumMinutes;
  final int maximumMinutes;
  final List<StoicContext> contexts;
  final bool enabled;

  Activity copyWith({
    String? name,
    int? priority,
    int? dailyTargetMinutes,
    int? minimumMinutes,
    int? maximumMinutes,
    List<StoicContext>? contexts,
    bool? enabled,
  }) {
    return Activity(
      id: id,
      name: name ?? this.name,
      priority: priority ?? this.priority,
      dailyTargetMinutes: dailyTargetMinutes ?? this.dailyTargetMinutes,
      minimumMinutes: minimumMinutes ?? this.minimumMinutes,
      maximumMinutes: maximumMinutes ?? this.maximumMinutes,
      contexts: contexts ?? this.contexts,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'priority': priority,
        'dailyTargetMinutes': dailyTargetMinutes,
        'minimumMinutes': minimumMinutes,
        'maximumMinutes': maximumMinutes,
        'contexts': contexts.map((e) => e.name).toList(),
        'enabled': enabled,
      };

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      name: json['name'] as String,
      priority: json['priority'] as int,
      dailyTargetMinutes: json['dailyTargetMinutes'] as int,
      minimumMinutes: json['minimumMinutes'] as int,
      maximumMinutes: json['maximumMinutes'] as int,
      contexts: (json['contexts'] as List<dynamic>)
          .map((e) => StoicContext.values.byName(e as String))
          .toList(),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
