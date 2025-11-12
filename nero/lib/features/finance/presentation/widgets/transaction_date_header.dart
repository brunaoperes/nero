import 'package:flutter/material.dart';

/// Header sticky para agrupar transações por data
class TransactionDateHeader extends StatelessWidget {
  final String label; // "Hoje", "Ontem", "12 de novembro"
  final bool isDark;

  const TransactionDateHeader({
    super.key,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDark ? const Color(0xFF121212) : Colors.white,
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF212121),
              letterSpacing: 0.2,
            ),
            semanticsLabel: 'Transações de $label',
          ),
        ],
      ),
    );
  }
}

/// SliverPersistentHeader delegate para sticky header
class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String label;
  final bool isDark;
  final double height;

  StickyHeaderDelegate({
    required this.label,
    required this.isDark,
    this.height = 40,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return TransactionDateHeader(
      label: label,
      isDark: isDark,
    );
  }

  @override
  bool shouldRebuild(StickyHeaderDelegate oldDelegate) {
    return label != oldDelegate.label || isDark != oldDelegate.isDark;
  }
}
