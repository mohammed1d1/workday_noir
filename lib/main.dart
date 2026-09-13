import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'data/database/workday_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await WorkdayDatabase.open();
  runApp(ProviderScope(overrides: [databaseProvider.overrideWithValue(database)], child: const WorkdayNoirApp()));
}
