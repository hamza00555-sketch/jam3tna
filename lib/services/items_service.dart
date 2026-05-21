import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/enums.dart';
import '../models/item.dart';

class ItemClaimConflictException implements Exception {
  final String message;
  const ItemClaimConflictException(this.message);
  @override
  String toString() => message;
}

class ItemsService {
  ItemsService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('items');

  /// بثّ كل البنود مرتّبة حسب الفئة ثم slotIndex.
  Stream<List<Item>> watchAll() {
    return _col.orderBy('category').snapshots().map(
          (QuerySnapshot<Map<String, dynamic>> snap) => snap.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
                  Item.fromFirestore(d))
              .toList()
            ..sort(_compareItems),
        );
  }

  int _compareItems(Item a, Item b) {
    final int byCat = a.category.index.compareTo(b.category.index);
    if (byCat != 0) return byCat;
    // slots قبل الحرّة.
    if (a.isSlot && b.isFreeItem) return -1;
    if (a.isFreeItem && b.isSlot) return 1;
    if (a.isSlot && b.isSlot) {
      return (a.slotIndex ?? 0).compareTo(b.slotIndex ?? 0);
    }
    return a.createdAt.compareTo(b.createdAt);
  }

  /// حجز slot موجود — Firestore transaction آمنة ضد race conditions.
  /// ترمي [ItemClaimConflictException] إذا كان البند محجوزاً من شخص آخر.
  Future<void> claimItem({
    required String itemId,
    required String uid,
    required String displayName,
    required String itemName,
    String? notes,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref = _col.doc(itemId);
    await _db.runTransaction((Transaction tx) async {
      final DocumentSnapshot<Map<String, dynamic>> snap = await tx.get(ref);
      if (!snap.exists) {
        throw const ItemClaimConflictException('البند لم يعد موجوداً.');
      }
      final Map<String, dynamic>? data = snap.data();
      final String? claimedBy = data?['claimedByUid'] as String?;
      if (claimedBy != null && claimedBy != uid) {
        final String claimerName =
            (data?['claimedByName'] as String?) ?? 'أحد الأعضاء';
        throw ItemClaimConflictException('سبقك $claimerName في حجزه.');
      }
      tx.update(ref, <String, Object?>{
        'claimedByUid': uid,
        'claimedByName': displayName,
        'itemName': itemName.trim(),
        'notes': notes?.trim().isEmpty ?? true ? null : notes!.trim(),
        'claimedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// تعديل بند محجوز (صاحبه فقط — يُتحقّق على مستوى الواجهة + rules لاحقاً).
  Future<void> updateClaim({
    required String itemId,
    required String uid,
    required String itemName,
    String? notes,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref = _col.doc(itemId);
    await _db.runTransaction((Transaction tx) async {
      final DocumentSnapshot<Map<String, dynamic>> snap = await tx.get(ref);
      final String? owner = snap.data()?['claimedByUid'] as String?;
      if (owner != uid) {
        throw const ItemClaimConflictException(
          'لا يمكن تعديل بند ليس لك.',
        );
      }
      tx.update(ref, <String, Object?>{
        'itemName': itemName.trim(),
        'notes': notes?.trim().isEmpty ?? true ? null : notes!.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// إلغاء حجز (صاحبه فقط). إن كان slot يُعاد لـ "متاح"؛ إن كان حرّاً يُحذف.
  Future<void> unclaimItem({
    required String itemId,
    required String uid,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref = _col.doc(itemId);
    await _db.runTransaction((Transaction tx) async {
      final DocumentSnapshot<Map<String, dynamic>> snap = await tx.get(ref);
      final Map<String, dynamic>? data = snap.data();
      if (data == null) {
        throw const ItemClaimConflictException('البند غير موجود.');
      }
      final String? owner = data['claimedByUid'] as String?;
      if (owner != uid) {
        throw const ItemClaimConflictException('لا يمكن إلغاء بند ليس لك.');
      }
      final int? slotIdx = data['slotIndex'] as int?;
      if (slotIdx == null) {
        // بند حرّ → حذف كامل.
        tx.delete(ref);
      } else {
        // slot → تفريغ الحقول.
        tx.update(ref, <String, Object?>{
          'claimedByUid': null,
          'claimedByName': null,
          'itemName': null,
          'notes': null,
          'claimedAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// إضافة بند حرّ (خارج slots) محجوز فوراً لمن أنشأه.
  Future<void> addFreeItem({
    required String uid,
    required String displayName,
    required ItemCategory category,
    required ItemSection section,
    required String itemName,
    String? notes,
  }) async {
    await _col.add(<String, Object?>{
      'category': category.key,
      'section': section.key,
      'slotIndex': null,
      'claimedByUid': uid,
      'claimedByName': displayName,
      'itemName': itemName.trim(),
      'notes': notes?.trim().isEmpty ?? true ? null : notes!.trim(),
      'claimedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdByUid': uid,
    });
  }
}
