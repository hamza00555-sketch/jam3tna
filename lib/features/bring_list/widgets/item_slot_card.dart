import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/item.dart';

class ItemSlotCard extends StatelessWidget {
  const ItemSlotCard({
    super.key,
    required this.item,
    required this.isMine,
    required this.onTap,
    this.onEdit,
    this.onUnclaim,
  });

  final Item item;
  final bool isMine;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onUnclaim;

  @override
  Widget build(BuildContext context) {
    if (item.isClaimed) {
      return _ClaimedCard(
        item: item,
        isMine: isMine,
        onEdit: onEdit,
        onUnclaim: onUnclaim,
      );
    }
    return _AvailableCard(item: item, onTap: onTap);
  }
}

class _AvailableCard extends StatelessWidget {
  const _AvailableCard({required this.item, required this.onTap});
  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: EidColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: EidColors.gold.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.add_circle_outline,
                color: EidColors.gold,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'متاح للحجز',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: EidColors.darkGreen,
                  ),
                ),
              ),
              _SectionChip(sectionKey: item.section.key, label: item.section.labelAr),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClaimedCard extends StatelessWidget {
  const _ClaimedCard({
    required this.item,
    required this.isMine,
    this.onEdit,
    this.onUnclaim,
  });

  final Item item;
  final bool isMine;
  final VoidCallback? onEdit;
  final VoidCallback? onUnclaim;

  @override
  Widget build(BuildContext context) {
    final Color tone = isMine ? EidColors.gold : EidColors.green;
    return Container(
      decoration: BoxDecoration(
        color: EidColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.4), width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tone.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMine ? Icons.bookmark : Icons.check_circle_outline,
              color: tone,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.itemName ?? '—',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: EidColors.darkGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _SectionChip(sectionKey: item.section.key, label: item.section.labelAr),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isMine ? 'محجوز باسمك' : 'محجوز · ${item.claimedByName ?? "عضو"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: tone,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.notes != null && item.notes!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    item.notes!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: EidColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (isMine)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: EidColors.textSecondary),
              onSelected: (String v) {
                if (v == 'edit' && onEdit != null) onEdit!();
                if (v == 'unclaim' && onUnclaim != null) onUnclaim!();
              },
              itemBuilder: (BuildContext ctx) => const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(value: 'edit', child: Text('تعديل')),
                PopupMenuItem<String>(value: 'unclaim', child: Text('إلغاء الحجز')),
              ],
            ),
        ],
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({required this.sectionKey, required this.label});
  final String sectionKey;
  final String label;

  @override
  Widget build(BuildContext context) {
    Color tone;
    switch (sectionKey) {
      case 'men':
        tone = EidColors.green;
        break;
      case 'women':
        tone = EidColors.accentRose;
        break;
      default:
        tone = EidColors.gold;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tone.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: tone,
        ),
      ),
    );
  }
}
