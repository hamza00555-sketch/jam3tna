import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class EidAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EidAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showCrescent = true,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showCrescent;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showCrescent) ...<Widget>[
            const Icon(Icons.brightness_2, color: EidColors.gold, size: 20),
            const SizedBox(width: 8),
          ],
          Text(title),
        ],
      ),
      leading: leading,
      actions: actions,
    );
  }
}
