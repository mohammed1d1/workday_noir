import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/workday_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Section(
              children: [
                CupertinoListTile(
                  title: const Text('Appearance'),
                  leading: const Icon(CupertinoIcons.moon),
                  trailing: const Icon(CupertinoIcons.chevron_right),
                  onTap: () => _showAppearance(context),
                ),
                CupertinoListTile(
                  title: const Text('Daily Reminder'),
                  leading: const Icon(CupertinoIcons.bell),
                  trailing: const Icon(CupertinoIcons.chevron_right),
                  onTap: () => _comingSoon(context),
                ),
                CupertinoListTile(
                  title: const Text('Export'),
                  leading: const Icon(CupertinoIcons.square_arrow_up),
                  trailing: const Icon(CupertinoIcons.chevron_right),
                  onTap: () => _comingSoon(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _Section(
              children: [
                CupertinoListTile(
                  title: const Text(
                    'Delete All Data',
                    style: TextStyle(color: CupertinoColors.systemRed),
                  ),
                  leading: const Icon(
                    CupertinoIcons.trash,
                    color: CupertinoColors.systemRed,
                  ),
                  onTap: () => _delete(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Workday Noir · 1.0.0',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAppearance(BuildContext context) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: const Text('Appearance'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheetContext),
            child: const Text('Noir'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheetContext),
            child: const Text('System'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheetContext),
            child: const Text('Light'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Delete all work history?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(repositoryProvider).deleteAll();
      ref.invalidate(entriesProvider);
      ref.invalidate(todayEntryProvider);
    } catch (_) {
      if (!context.mounted) return;
      await showCupertinoDialog<void>(
        context: context,
        builder: (_) => const CupertinoAlertDialog(
          title: Text('Unable to delete'),
          content: Text('Something went wrong. Please try again.'),
          actions: [CupertinoDialogAction(child: Text('OK'))],
        ),
      );
    }
  }

  Future<void> _comingSoon(BuildContext context) => showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Coming next'),
          content: const Text(
            'This option is reserved for the native integration layer.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131316),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }
}
