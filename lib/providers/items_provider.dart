import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../models/item.dart';
import '../services/items_service.dart';

final itemsServiceProvider = Provider<ItemsService>((Ref ref) {
  return ItemsService();
});

/// كل البنود (بدون فلترة).
final allItemsProvider = StreamProvider<List<Item>>((Ref ref) {
  return ref.watch(itemsServiceProvider).watchAll();
});

/// فلتر مرئي حسب اختيار المستخدم في Bring List.
enum BringListFilter { mine, shared, all }

final bringListFilterProvider =
    StateProvider<BringListFilter>((Ref ref) => BringListFilter.all);

/// البنود المرئيّة بناءً على الفلتر والقسم.
final filteredItemsProvider =
    Provider.family<List<Item>, UserSection?>((Ref ref, UserSection? mySection) {
  final List<Item> all = ref.watch(allItemsProvider).value ?? <Item>[];
  final BringListFilter filter = ref.watch(bringListFilterProvider);

  switch (filter) {
    case BringListFilter.all:
      return all;
    case BringListFilter.shared:
      return all
          .where((Item i) => i.section == ItemSection.shared)
          .toList();
    case BringListFilter.mine:
      if (mySection == null) return <Item>[];
      final ItemSection mine = mySection == UserSection.men
          ? ItemSection.men
          : ItemSection.women;
      return all
          .where((Item i) => i.section == mine || i.section == ItemSection.shared)
          .toList();
  }
});
