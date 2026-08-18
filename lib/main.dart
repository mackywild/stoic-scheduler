import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/repository/local_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = LocalRepository();
  await repository.initialize();
  runApp(StoicSchedulerApp(repository: repository));
}
