import 'package:flutter/material.dart';

import 'models/activity.dart';
import 'models/execution_record.dart';
import 'repository/local_repository.dart';
import 'screens/activities_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';

class StoicSchedulerApp extends StatefulWidget {
  const StoicSchedulerApp({super.key, required this.repository});

  final LocalRepository repository;

  @override
  State<StoicSchedulerApp> createState() => _StoicSchedulerAppState();
}

class _StoicSchedulerAppState extends State<StoicSchedulerApp> {
  int _index = 0;

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final List<Activity> activities = widget.repository.activities;
    final List<ExecutionRecord> records = widget.repository.records;

    final pages = [
      HomeScreen(
        repository: widget.repository,
        activities: activities,
        records: records,
        onChanged: _refresh,
      ),
      ActivitiesScreen(
        repository: widget.repository,
        activities: activities,
        onChanged: _refresh,
      ),
      HistoryScreen(records: records, activities: activities),
      StatsScreen(records: records),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'STOIC SCHEDULER',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF111111),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0B0B),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(child: pages[_index]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.bolt_outlined),
              selectedIcon: Icon(Icons.bolt),
              label: '指令',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: '行動',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: '履歴',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: '統計',
            ),
          ],
        ),
      ),
    );
  }
}
