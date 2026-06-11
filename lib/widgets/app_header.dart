import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String? title;
  final bool showBell;
  final bool showBack;

  const AppHeader({
    super.key,
    this.title,
    this.showBell = true,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      child: Row(
        children: [
          if (showBack)
            const Icon(Icons.arrow_back_ios_new_rounded, size: 20)
          else
            const SizedBox(width: 20),
          Expanded(
            child: Center(
              child: Text(
                title ?? 'STYLELEAGUE',
                style: const TextStyle(
                  letterSpacing: 6,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          showBell
              ? const Icon(Icons.notifications_none_rounded, size: 24)
              : const SizedBox(width: 24),
        ],
      ),
    );
  }
}