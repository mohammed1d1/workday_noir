import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/date_utils.dart';
import '../../data/models/work_entry.dart';
import '../../data/repositories/workday_repository.dart';
import '../../shared/widgets/noir_card.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(todayEntryProvider);
    final date = todayLocal();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('WORKDAY'),
        automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: entry.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, _) => const Center(child: Text('Something went wrong.')),
          data: (value) => _TodayBody(date: date, entry: value),
        ),
      ),
    );
  }
}

class _TodayBody extends ConsumerWidget {
  const _TodayBody({required this.date, required this.entry});

  final DateTime date;
  final WorkEntry? entry;

  Future<void> _save(BuildContext context, WidgetRef ref, WorkStatus status) async {
    try {
      await ref.read(repositoryProvider).record(date, status, note: entry?.note);
      ref.invalidate(todayEntryProvider);
      ref.invalidate(entriesProvider);
      await HapticFeedback.lightImpact();
    } catch (_) {
      if (!context.mounted) return;
      await showCupertinoDialog<void>(
        context: context,
        builder: (_) => const CupertinoAlertDialog(
          title: Text('Unable to save'),
          content: Text('Something went wrong. Please try again.'),
          actions: [CupertinoDialogAction(child: Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worked = entry?.status == WorkStatus.worked;
    final didNotWork = entry?.status == WorkStatus.didNotWork;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        Text(
          DateFormat('MMMM d, yyyy').format(date),
          style: const TextStyle(
            fontSize: 18,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE').format(date),
          style: const TextStyle(
            fontSize: 15,
            color: CupertinoColors.systemGrey2,
          ),
        ),
        const SizedBox(height: 70),
        const Text(
          'Did you work today?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 32),
        _ActionButton(
          label: 'YES',
          icon: CupertinoIcons.check_mark,
          selected: worked,
          onTap: () => _save(context, ref, WorkStatus.worked),
        ),
        const SizedBox(height: 14),
        _ActionButton(
          label: 'NO',
          icon: CupertinoIcons.xmark,
          selected: didNotWork,
          onTap: () => _save(context, ref, WorkStatus.didNotWork),
        ),
        if (entry != null) ...[
          const SizedBox(height: 26),
          NoirCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worked ? 'Worked today ✓' : "Didn't work today ×",
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Saved for ${DateFormat('MMMM d').format(date)}',
                  style: const TextStyle(color: CupertinoColors.systemGrey),
                ),
                const SizedBox(height: 14),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _save(
                    context,
                    ref,
                    worked ? WorkStatus.didNotWork : WorkStatus.worked,
                  ),
                  child: const Text('Change answer'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label == 'YES' ? 'Worked today' : "Didn't work today",
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 76,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF242428)
                : const Color(0xFF151518),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? const Color(0x66FFFFFF)
                  : const Color(0x18FFFFFF),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
