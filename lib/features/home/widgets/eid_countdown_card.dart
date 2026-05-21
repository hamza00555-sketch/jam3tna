import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';

class EidCountdownCard extends StatelessWidget {
  const EidCountdownCard({
    super.key,
    required this.eventDate,
    required this.displayName,
    required this.sectionLabel,
  });

  final DateTime? eventDate;
  final String displayName;
  final String sectionLabel;

  @override
  Widget build(BuildContext context) {
    final int days = EidDateUtils.daysUntil(eventDate);
    final String hijri = EidDateUtils.todayHijri();
    final String countdownLabel = _countdownText(days);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[EidColors.darkGreen, EidColors.green],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: EidColors.darkGreen.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.brightness_2, color: EidColors.gold, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'كل عام وأنتم بخير',
                  style: TextStyle(
                    color: EidColors.gold.withValues(alpha: 0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                hijri,
                style: TextStyle(
                  color: EidColors.cream.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'مرحباً $displayName',
            style: const TextStyle(
              color: EidColors.cream,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sectionLabel,
            style: TextStyle(
              color: EidColors.gold.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: EidColors.cream.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: EidColors.gold.withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.event_available,
                  color: EidColors.gold,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  countdownLabel,
                  style: const TextStyle(
                    color: EidColors.cream,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _countdownText(int days) {
    if (eventDate == null) {
      return 'لم يُحدّد تاريخ الرحلة بعد';
    }
    if (days < 0) return 'انتهت الرحلة';
    if (days == 0) return 'اليوم لمَّتنا 🌙';
    if (days == 1) return 'باقي يوم واحد على لمَّتنا';
    if (days == 2) return 'باقي يومان على لمَّتنا';
    if (days <= 10) return 'باقي $days أيام على لمَّتنا';
    return 'باقي $days يوماً على لمَّتنا';
  }
}
