import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../models/enums.dart';
import '../../models/item.dart';
import '../../providers/current_user_provider.dart';
import '../../providers/items_provider.dart';
import '../../services/items_service.dart';
import '../../widgets/eid_app_bar.dart';
import 'widgets/add_free_item_dialog.dart';
import 'widgets/category_section.dart';
import 'widgets/claim_item_dialog.dart';

class BringListScreen extends ConsumerWidget {
  const BringListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> userAsync = ref.watch(currentUserProvider);
    final AsyncValue<List<Item>> itemsAsync = ref.watch(allItemsProvider);
    final BringListFilter filter = ref.watch(bringListFilterProvider);

    return Scaffold(
      appBar: EidAppBar(
        title: 'قائمة الجلب',
        actions: <Widget>[
          if (userAsync.value?.isAdmin ?? false)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'إعدادات الفئات',
              onPressed: () => context.push(AppRoutes.bringListAdmin),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addFreeItem(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('بند إضافي'),
        backgroundColor: EidColors.gold,
        foregroundColor: EidColors.darkGreen,
      ),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: EidColors.gold),
        ),
        error: (Object err, _) => Center(child: Text('خطأ: $err')),
        data: (AppUser? user) {
          if (user == null) {
            return const Center(child: Text('غير مسجّل.'));
          }
          return Column(
            children: <Widget>[
              _FilterBar(
                filter: filter,
                onChanged: (BringListFilter f) =>
                    ref.read(bringListFilterProvider.notifier).state = f,
              ),
              Expanded(
                child: itemsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: EidColors.gold),
                  ),
                  error: (Object err, _) =>
                      Center(child: Text('خطأ: $err')),
                  data: (List<Item> _) {
                    final List<Item> items =
                        ref.watch(filteredItemsProvider(user.section));
                    if (items.isEmpty) {
                      return _EmptyState(user: user);
                    }
                    return _CategorizedList(
                      items: items,
                      user: user,
                      onClaim: (Item i) => _claimItem(context, ref, user, i),
                      onEdit: (Item i) => _editItem(context, ref, user, i),
                      onUnclaim: (Item i) => _unclaim(context, ref, user, i),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _claimItem(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
    Item item,
  ) async {
    if (item.isClaimed && item.claimedByUid != user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('محجوز بالفعل لـ ${item.claimedByName}.')),
      );
      return;
    }
    final ClaimItemResult? result = await ClaimItemDialog.show(
      context,
      categoryLabel: item.category.labelAr,
    );
    if (result == null) return;
    try {
      await ref.read(itemsServiceProvider).claimItem(
            itemId: item.id,
            uid: user.uid,
            displayName: user.displayName,
            itemName: result.itemName,
            notes: result.notes,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حجز "${result.itemName}".')),
      );
    } on ItemClaimConflictException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر الحجز: $e')),
      );
    }
  }

  Future<void> _editItem(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
    Item item,
  ) async {
    final ClaimItemResult? result = await ClaimItemDialog.showForItem(
      context,
      item: item,
      categoryLabel: item.category.labelAr,
    );
    if (result == null) return;
    try {
      await ref.read(itemsServiceProvider).updateClaim(
            itemId: item.id,
            uid: user.uid,
            itemName: result.itemName,
            notes: result.notes,
          );
    } on ItemClaimConflictException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  Future<void> _unclaim(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
    Item item,
  ) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('إلغاء الحجز'),
        content: Text('سيُعاد "${item.itemName ?? "البند"}" للقائمة المتاحة.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('إلغاء الحجز'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(itemsServiceProvider).unclaimItem(
            itemId: item.id,
            uid: user.uid,
          );
    } on ItemClaimConflictException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  Future<void> _addFreeItem(BuildContext context, WidgetRef ref) async {
    final AppUser? user = ref.read(currentUserProvider).value;
    if (user == null) return;
    final ItemSection defaultSection = user.section == UserSection.men
        ? ItemSection.men
        : user.section == UserSection.women
            ? ItemSection.women
            : ItemSection.shared;
    final AddFreeItemResult? result = await AddFreeItemDialog.show(
      context,
      defaultSection: defaultSection,
    );
    if (result == null) return;
    try {
      await ref.read(itemsServiceProvider).addFreeItem(
            uid: user.uid,
            displayName: user.displayName,
            category: result.category,
            section: result.section,
            itemName: result.itemName,
            notes: result.notes,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت الإضافة.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّرت الإضافة: $e')),
      );
    }
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.filter, required this.onChanged});
  final BringListFilter filter;
  final ValueChanged<BringListFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SegmentedButton<BringListFilter>(
        segments: const <ButtonSegment<BringListFilter>>[
          ButtonSegment<BringListFilter>(
            value: BringListFilter.mine,
            label: Text('قسمي'),
            icon: Icon(Icons.person_outline),
          ),
          ButtonSegment<BringListFilter>(
            value: BringListFilter.shared,
            label: Text('مشترك'),
            icon: Icon(Icons.groups_2_outlined),
          ),
          ButtonSegment<BringListFilter>(
            value: BringListFilter.all,
            label: Text('الكل'),
            icon: Icon(Icons.list),
          ),
        ],
        selected: <BringListFilter>{filter},
        onSelectionChanged: (Set<BringListFilter> s) {
          if (s.isNotEmpty) onChanged(s.first);
        },
      ),
    );
  }
}

class _CategorizedList extends StatelessWidget {
  const _CategorizedList({
    required this.items,
    required this.user,
    required this.onClaim,
    required this.onEdit,
    required this.onUnclaim,
  });

  final List<Item> items;
  final AppUser user;
  final void Function(Item) onClaim;
  final void Function(Item) onEdit;
  final void Function(Item) onUnclaim;

  @override
  Widget build(BuildContext context) {
    final Map<ItemCategory, List<Item>> grouped = <ItemCategory, List<Item>>{};
    for (final Item i in items) {
      grouped.putIfAbsent(i.category, () => <Item>[]).add(i);
    }
    final List<ItemCategory> ordered = ItemCategory.values
        .where((ItemCategory c) => grouped.containsKey(c))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: ordered.length,
      itemBuilder: (BuildContext ctx, int idx) {
        final ItemCategory cat = ordered[idx];
        return CategorySection(
          category: cat,
          items: grouped[cat]!,
          currentUid: user.uid,
          onClaim: onClaim,
          onEdit: onEdit,
          onUnclaim: onUnclaim,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.checklist_rtl,
              size: 64,
              color: EidColors.gold,
            ),
            const SizedBox(height: 12),
            Text(
              user.isAdmin
                  ? 'لم تُضَف فئات بعد.\nادخل إعدادات الفئات لتحديد الكوتا.'
                  : 'لم يضِف المشرف فئات بعد.\nيمكنك إضافة بند إضافي يدوياً.',
              textAlign: TextAlign.center,
              style: const TextStyle(
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
}
