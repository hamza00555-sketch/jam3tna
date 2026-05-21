import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
    this.enabled = true,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? badge;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color tone = enabled ? color : EidColors.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: EidColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tone.withValues(alpha: 0.25), width: 1),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: tone.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: tone.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, size: 28, color: tone),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: enabled ? EidColors.darkGreen : EidColors.textSecondary,
                      ),
                    ),
                    if (!enabled) ...<Widget>[
                      const SizedBox(height: 4),
                      const Text(
                        'قريباً',
                        style: TextStyle(
                          fontSize: 11,
                          color: EidColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (badge != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: EidColors.gold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: EidColors.darkGreen,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
