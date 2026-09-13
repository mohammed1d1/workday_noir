import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/history/history_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/statistics/statistics_screen.dart';
import '../features/today/today_screen.dart';

class WorkdayNoirApp extends ConsumerWidget {
  const WorkdayNoirApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appearanceProvider);
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Workday Noir',
      theme: noirTheme(Brightness.dark),
      home: AppShell(appearanceMode: mode),
    );
  }
}

enum AppearanceMode { noir, system, light }
final appearanceProvider = StateProvider<AppearanceMode>((ref) => AppearanceMode.noir);

class AppShell extends StatefulWidget {
  final AppearanceMode appearanceMode;
  const AppShell({super.key, required this.appearanceMode});
  @override State<AppShell> createState() => _AppShellState();
}
class _AppShellState extends State<AppShell> {
  int index = 0;
  final pages = const [TodayScreen(), CalendarScreen(), HistoryScreen(), StatisticsScreen(), SettingsScreen()];
  @override
  Widget build(BuildContext context) => CupertinoTabScaffold(
    tabBar: CupertinoTabBar(
      backgroundColor: const Color(0xE60A0A0C),
      activeColor: CupertinoColors.white,
      inactiveColor: CupertinoColors.systemGrey,
      items: const [
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.today), label: 'Today'),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.calendar), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.list_bullet), label: 'History'),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.chart_bar), label: 'Statistics'),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'Settings'),
      ],
    ),
    tabBuilder: (_, i) => CupertinoTabView(builder: (_) => pages[i]),
  );
}
