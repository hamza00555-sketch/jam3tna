import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../models/item.dart';
import '../../providers/current_user_provider.dart';
import '../../providers/items_provider.dart';
import '../../widgets/eid_app_bar.dart';
import 'widgets/item_slot_card.dart';

class MyItemsScreen extends ConsumerWidget {
  const MyItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> userAsync = ref.watch(currentUserProvider);
    final AsyncValue<List<Item>> itemsAsync = ref.watch(allItemsProvider);

    return Scaffold(
      appBar: const EidAppBar(title: 'بنوديّ'),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: EidColors.gold),
        ),
        error: (Object err, _) => Center(child: Text('خطأ: $err')),
        data: (AppUser? user) {
          if (user == null) {
            return const Center(child: Text('غير مسجّل.'));
          }
          return itemsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: EidColors.gold),
            ),
            error: (Object err, _) => Center(child: Text('خطأ: $err')),
            data: (List<Item> all) {
              final List<Item> mine = all
                  .where((Item i) => i.claimedByUid == user.uid)
                  .toList();
              if (mine.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.shopping_basket_outlined,
                          size: 64,
                          color: EidColors.gold,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'لم تحجز شيئاً بعد.\nاذهب لقائمة الجلب وحدّد ما ستجلبه.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: EidColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: EidColors.gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.checklist,
                          color: EidColors.darkGreen,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'عليك جلب ${mine.length} بند${_arSuffix(mine.length)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: EidColors.darkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...mine.map((Item i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: ItemSlotCard(
                          item: i,
                          isMine: true,
                          onTap: () {},
                          onEdit: null,
                          onUnclaim: null,
                        ),
                      )),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _arSuffix(int n) {
    if (n == 1) return 'اً';
    if (n == 2) return 'ين';
    return '';
  }
}
