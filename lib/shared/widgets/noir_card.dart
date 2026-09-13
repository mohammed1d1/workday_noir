import 'package:flutter/cupertino.dart';
class NoirCard extends StatelessWidget {
  final Widget child; final EdgeInsets padding; final VoidCallback? onTap;
  const NoirCard({super.key, required this.child, this.padding = const EdgeInsets.all(20), this.onTap});
  @override Widget build(BuildContext context) { final card = Container(decoration: BoxDecoration(color: const Color(0xFF131316), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0x18FFFFFF))), padding: padding, child: child); return onTap == null ? card : GestureDetector(onTap: onTap, child: card); }
}
