import 'package:flutter/material.dart';

/// Shared "coming soon" body for bottom-nav tabs that don't have a design yet.
class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  static const Color navy = Color(0xFF173C66);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: navy.withValues(alpha: 0.35)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: navy,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'قريباً',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9AA1AC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
