import 'package:flutter/material.dart';

import '../../app/theme/noir_theme.dart';
import '../../services/export_service.dart';
import '../../services/work_entries_controller.dart';
import '../../widgets/month_section.dart';

/// Work history grouped by month, most recent month first. Tapping any
/// day toggles its status in place (no duplicate entries are ever
/// created — see [WorkEntriesController.setDay]).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.controller});

  final WorkEntriesController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        if (controller.isLoading) {
          return const SizedBox.shrink();
        }

        final List<MonthGroup> months = controller.groupedByMonth;

        return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: false,
              floating: true,
              title: const Text('History'),
              actions: <Widget>[
                if (months.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(
                      child: Text(
                        '${controller.totalWorkedDaysOverall} total',
                        style: NoirTypography.caption,
                      ),
                    ),
                  ),
              ],
            ),
            if (months.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: const _EmptyHistory(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return MonthSection(
                        group: months[index],
                        onToggleEntry: (DateTime date, bool worked) {
                          controller.setDay(date: date, worked: worked);
                        },
                      );
                    },
                    childCount: months.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'No workdays yet.',
              style: NoirTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start by answering today\'s question.',
              style: NoirTypography.secondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
