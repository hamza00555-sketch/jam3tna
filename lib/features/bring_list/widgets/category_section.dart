import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/item.dart';
import 'item_slot_card.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({
    super.key,
    required this.category,
    required this.items,
    required this.currentUid,
    required this.onClaim,
    required this.onEdit,
    required this.onUnclaim,
  });

  final ItemCategory category;
  final List<Item> items;
  final String currentUid;
  final void Function(Item) onClaim;
  final void Function(Item) onEdit;
  final void Function(Item) onUnclaim;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final int claimedCount =
        items.where((Item i) => i.isClaimed).length;
    final int total = items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
          child: Row(
            children: <Widget>[
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: EidColors.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                category.labelAr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: EidColors.darkGreen,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: EidColors.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$claimedCount / $total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: EidColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((Item i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ItemSlotCard(
                item: i,
                isMine: i.claimedByUid == currentUid,
                onTap: () => onClaim(i),
                onEdit: () => onEdit(i),
                onUnclaim: () => onUnclaim(i),
              ),
            )),
      ],
    );
  }
}
