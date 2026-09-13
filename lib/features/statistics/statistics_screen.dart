import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/date_utils.dart';
import '../../data/models/work_entry.dart';
import '../../data/repositories/workday_repository.dart';
import '../../shared/widgets/noir_card.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(entriesProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Statistics'),
        automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: entries.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, _) => const Center(child: Text('Something went wrong.')),
          data: (items) {
            final now = todayLocal();
            final monthEntries = items
                .where((entry) => entry.date.startsWith(monthKey(now)))
                .toList();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _StatsCard(
                  title: DateFormat('MMMM yyyy').format(now),
                  entries: monthEntries,
                ),
                const SizedBox(height: 18),
                _StatsCard(title: 'All time', entries: items),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.title, required this.entries});

  final String title;
  final List<WorkEntry> entries;

  @override
  Widget build(BuildContext context) {
    final worked =
        entries.where((entry) => entry.status == WorkStatus.worked).length;
    final rate = entries.isEmpty ? 0 : (worked / entries.length * 100).round();

    return NoirCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              letterSpacing: 1.2,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _Metric(label: 'Worked', value: '$worked')),
              Expanded(
                child: _Metric(
                  label: "Didn't work",
                  value: '${entries.length - worked}',
                ),
              ),
              Expanded(child: _Metric(label: 'Rate', value: '$rate%')),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Total recorded  ${entries.length}',
            style: const TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
