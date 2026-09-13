import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/date_utils.dart';
import '../../data/models/work_entry.dart';
import '../../data/repositories/workday_repository.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<CalendarScreen> {
  DateTime month = DateTime(todayLocal().year, todayLocal().month);

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(entriesProvider);
    final currentMonth = DateTime(todayLocal().year, todayLocal().month);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Calendar'),
        automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: entries.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, _) => const Center(child: Text('Something went wrong.')),
          data: (all) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => setState(
                      () => month = DateTime(month.year, month.month - 1),
                    ),
                    child: const Icon(CupertinoIcons.chevron_left),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(month),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: month.isBefore(currentMonth)
                        ? () => setState(
                              () => month = DateTime(month.year, month.month + 1),
                            )
                        : null,
                    child: const Icon(CupertinoIcons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _CalendarGrid(
                month: month,
                entries: all,
                onEdit: (date, entry) => _edit(date, entry),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tap a previous day to edit its status.',
                style: TextStyle(color: CupertinoColors.systemGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _edit(DateTime date, WorkEntry? entry) async {
    final status = await showCupertinoModalPopup<WorkStatus>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(DateFormat('MMMM d, yyyy').format(date)),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheetContext, WorkStatus.worked),
            child: Text(
              'Worked ${entry?.status == WorkStatus.worked ? '✓' : ''}',
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () =>
                Navigator.pop(sheetContext, WorkStatus.didNotWork),
            child: Text(
              "Didn't work ${entry?.status == WorkStatus.didNotWork ? '×' : ''}",
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Cancel'),
        ),
      ),
    );

    if (status == null || !mounted) return;

    await ref.read(repositoryProvider).record(date, status, note: entry?.note);
    ref.invalidate(entriesProvider);
    ref.invalidate(todayEntryProvider);
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.entries,
    required this.onEdit,
  });

  final DateTime month;
  final List<WorkEntry> entries;
  final Future<void> Function(DateTime, WorkEntry?) onEdit;

  @override
  Widget build(BuildContext context) {
    final byDate = {for (final entry in entries) entry.date: entry};
    final first = DateTime(month.year, month.month, 1);
    final days = DateTime(month.year, month.month + 1, 0).day;
    final offset = first.weekday - DateTime.monday;
    final cells = <Widget>[];

    for (var i = 0; i < offset; i++) {
      cells.add(const SizedBox());
    }

    for (var day = 1; day <= days; day++) {
      final date = DateTime(month.year, month.month, day);
      final entry = byDate[dateKey(date)];
      final future = date.isAfter(todayLocal());
      final today = dateKey(date) == dateKey(todayLocal());

      cells.add(
        GestureDetector(
          onTap: future ? null : () => onEdit(date, entry),
          child: Semantics(
            label: '${DateFormat('MMMM d').format(date)}'
                '${entry == null ? ', not recorded' : entry.status == WorkStatus.worked ? ', worked' : ", didn't work"}',
            button: !future,
            child: Container(
              margin: const EdgeInsets.all(3),
              height: 48,
              decoration: BoxDecoration(
                color: entry == null
                    ? const Color(0xFF121215)
                    : const Color(0xFF1D1D21),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: today
                      ? const Color(0x99FFFFFF)
                      : const Color(0x10FFFFFF),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      color: future
                          ? CupertinoColors.systemGrey4
                          : CupertinoColors.white,
                    ),
                  ),
                  if (entry != null)
                    Icon(
                      entry.status == WorkStatus.worked
                          ? CupertinoIcons.check_mark
                          : CupertinoIcons.xmark,
                      size: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final day in weekdays)
          Center(
            child: Text(
              day,
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 12,
              ),
            ),
          ),
        ...cells,
      ],
    );
  }
}
