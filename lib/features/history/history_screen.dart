import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/work_entry.dart';
import '../../data/repositories/workday_repository.dart';
import '../../shared/widgets/noir_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(entriesProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('History'),
        automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: entries.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, _) => const Center(child: Text('Something went wrong.')),
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Text('No workdays recorded yet.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final entry = items[index];
                final date = DateTime.parse(entry.date);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NoirCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          entry.status == WorkStatus.worked
                              ? CupertinoIcons.check_mark
                              : CupertinoIcons.xmark,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd/MM').format(date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                entry.status == WorkStatus.worked
                                    ? 'Worked'
                                    : "Didn't work",
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              if (entry.note?.isNotEmpty == true)
                                Text(
                                  entry.note!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: CupertinoColors.systemGrey2,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
