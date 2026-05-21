import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_config.dart';
import '../models/enums.dart';

/// يولّد slots لكل فئة بناءً على [AppConfig.categoriesConfig].
///
/// قواعد العمل:
/// - لكل (category, section) نُنشئ slots بـ slotIndex مرقّم 0..n-1.
/// - إذا الكوتا الجديدة > الموجود حالياً: نضيف الباقي.
/// - إذا الكوتا الجديدة < الموجود حالياً:
///   - نحذف الـ slots غير المحجوزة (من الأعلى للأسفل) فقط.
///   - نترك الـ slots المحجوزة كما هي (لا نضيع حجز عضو).
/// - البنود الحرّة (slotIndex == null) لا تتأثر إطلاقاً.
///
/// idempotent: تشغيل متكرّر بنفس الـ config آمن.
class ItemsBootstrapService {
  ItemsBootstrapService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _items =>
      _db.collection('items');

  Future<void> applyConfig(Map<String, CategoryQuota> categoriesConfig) async {
    for (final MapEntry<String, CategoryQuota> entry
        in categoriesConfig.entries) {
      final ItemCategory category = ItemCategory.fromKey(entry.key);
      final CategoryQuota quota = entry.value;
      final ItemSection section = ItemSection.fromKey(quota.sectionKey);
      await _reconcileCategory(
        category: category,
        section: section,
        desiredCount: quota.count,
      );
    }
  }

  Future<void> _reconcileCategory({
    required ItemCategory category,
    required ItemSection section,
    required int desiredCount,
  }) async {
    // اقرأ slots الموجودة (slotIndex != null) لهذه الفئة + القسم.
    final QuerySnapshot<Map<String, dynamic>> snap = await _items
        .where('category', isEqualTo: category.key)
        .where('section', isEqualTo: section.key)
        .get();

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> existingSlots =
        snap.docs
            .where((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                d.data()['slotIndex'] != null)
            .toList()
          ..sort((a, b) {
            final int ai = (a.data()['slotIndex'] as int?) ?? 0;
            final int bi = (b.data()['slotIndex'] as int?) ?? 0;
            return ai.compareTo(bi);
          });

    // اجمع indices المستخدمة.
    final Set<int> usedIndices = existingSlots
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
            (d.data()['slotIndex'] as int?) ?? 0)
        .toSet();

    final WriteBatch batch = _db.batch();

    if (desiredCount > existingSlots.length) {
      // أضِف slots الناقصة بـ indices غير مستخدمة.
      int needed = desiredCount - existingSlots.length;
      int idx = 0;
      while (needed > 0) {
        if (!usedIndices.contains(idx)) {
          final DocumentReference<Map<String, dynamic>> ref = _items.doc();
          batch.set(ref, <String, Object?>{
            'category': category.key,
            'section': section.key,
            'slotIndex': idx,
            'claimedByUid': null,
            'claimedByName': null,
            'itemName': null,
            'notes': null,
            'claimedAt': null,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          usedIndices.add(idx);
          needed--;
        }
        idx++;
      }
    } else if (desiredCount < existingSlots.length) {
      // احذف slots غير المحجوزة فقط، من الأعلى للأسفل.
      final List<QueryDocumentSnapshot<Map<String, dynamic>>>
          deletableUnclaimed = existingSlots
              .where((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                  d.data()['claimedByUid'] == null)
              .toList()
            ..sort((a, b) {
              final int ai = (a.data()['slotIndex'] as int?) ?? 0;
              final int bi = (b.data()['slotIndex'] as int?) ?? 0;
              return bi.compareTo(ai); // من الأعلى للأسفل
            });

      int toDelete = existingSlots.length - desiredCount;
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d
          in deletableUnclaimed) {
        if (toDelete == 0) break;
        batch.delete(d.reference);
        toDelete--;
      }
    }

    await batch.commit();
  }
}
