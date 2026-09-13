import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme/noir_theme.dart';

enum WorkStatusChoice { yes, no }

/// The primary YES/NO button used on the Home screen.
///
/// Outlined and minimal at rest, matching the "no default Material-looking
/// buttons" direction. When [selected], it fills with a subtle tonal
/// background rather than a bright color, and a light haptic fires on tap.
class WorkStatusButton extends StatefulWidget {
  const WorkStatusButton({
    super.key,
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final WorkStatusChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<WorkStatusButton> createState() => _WorkStatusButtonState();
}

class _WorkStatusButtonState extends State<WorkStatusButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    lowerBound: 0.0,
    upperBound: 0.06,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isYes => widget.choice == WorkStatusChoice.yes;

  String get _label => _isYes ? 'YES' : 'NO';

  Color get _accent =>
      _isYes ? NoirColors.workedAccent : NoirColors.notWorkedAccent;

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final bool selected = widget.selected;

    return Semantics(
      button: true,
      selected: selected,
      label: _isYes ? 'Worked today' : 'Did not work today',
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final double scale = 1.0 - _controller.value;
            return Transform.scale(scale: scale, child: child);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minHeight: 56, minWidth: 128),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: selected
                  ? _accent.withOpacity(0.16)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? _accent.withOpacity(0.55)
                    : NoirColors.hairline,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(_label, style: NoirTypography.button),
                if (selected) ...<Widget>[
                  const SizedBox(width: 10),
                  Icon(
                    _isYes ? Icons.check_rounded : Icons.close_rounded,
                    size: 18,
                    color: _accent,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
