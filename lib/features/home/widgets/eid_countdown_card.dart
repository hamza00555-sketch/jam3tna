import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';

class EidCountdownCard extends StatelessWidget {
  const EidCountdownCard({
    super.key,
    required this.eidDate,
    required this.gatheringDate,
    required this.displayName,
    required this.sectionLabel,
    this.onTapEidDay,
  });

  final DateTime? eidDate;
  final DateTime? gatheringDate;
  final String displayName;
  final String sectionLabel;
  final VoidCallback? onTapEidDay;

  @override
  Widget build(BuildContext context) {
    final String hijri = EidDateUtils.todayHijri();
    final bool isEidToday = EidDateUtils.isToday(eidDate);

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
          const SizedBox(height: 18),
          if (isEidToday)
            _EidTodayBanner(onTap: onTapEidDay)
          else
            Row(
              children: <Widget>[
                Expanded(
                  child: _CountdownPill(
                    icon: Icons.brightness_2,
                    label: 'العيد',
                    value: EidDateUtils.countdownText(target: eidDate),
                    isHighlighted: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CountdownPill(
                    icon: Icons.event_available,
                    label: 'الاستراحة',
                    value: EidDateUtils.countdownText(target: gatheringDate),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CountdownPill extends StatelessWidget {
  const _CountdownPill({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final Color border = isHighlighted
        ? EidColors.gold.withValues(alpha: 0.7)
        : EidColors.gold.withValues(alpha: 0.35);
    final Color bg = isHighlighted
        ? EidColors.gold.withValues(alpha: 0.16)
        : EidColors.cream.withValues(alpha: 0.08);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: EidColors.gold, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: EidColors.gold.withValues(alpha: 0.95),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: EidColors.cream,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EidTodayBanner extends StatelessWidget {
  const _EidTodayBanner({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: EidColors.gold,
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: EidColors.gold.withValues(alpha: 0.45),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              const Text('🌙', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'اليوم عيد مبارك!',
                      style: TextStyle(
                        color: EidColors.darkGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'اضغط للاحتفال بالتكبيرات والألعاب النارية',
                      style: TextStyle(
                        color: EidColors.darkGreen,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.celebration,
                color: EidColors.darkGreen,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
