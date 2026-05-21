import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

class Item {
  final String id;
  final ItemCategory category;
  final ItemSection section;

  /// رقم الـ slot داخل الفئة (للبنود المولّدة من admin config).
  /// null للبنود الحرّة المضافة من الأعضاء.
  final int? slotIndex;

  final String? claimedByUid;
  final String? claimedByName;
  final String? itemName;
  final String? notes;

  final DateTime? claimedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// uid الذي أنشأ البند (للبنود الحرّة فقط).
  final String? createdByUid;

  const Item({
    required this.id,
    required this.category,
    required this.section,
    required this.createdAt,
    this.slotIndex,
    this.claimedByUid,
    this.claimedByName,
    this.itemName,
    this.notes,
    this.claimedAt,
    this.updatedAt,
    this.createdByUid,
  });

  bool get isClaimed => claimedByUid != null;
  bool get isFreeItem => slotIndex == null;
  bool get isSlot => slotIndex != null;

  factory Item.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    return Item(
      id: doc.id,
      category: ItemCategory.fromKey(data['category'] as String?),
      section: ItemSection.fromKey(data['section'] as String?),
      slotIndex: data['slotIndex'] as int?,
      claimedByUid: data['claimedByUid'] as String?,
      claimedByName: data['claimedByName'] as String?,
      itemName: data['itemName'] as String?,
      notes: data['notes'] as String?,
      claimedAt: (data['claimedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdByUid: data['createdByUid'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'category': category.key,
      'section': section.key,
      'slotIndex': slotIndex,
      'claimedByUid': claimedByUid,
      'claimedByName': claimedByName,
      'itemName': itemName,
      'notes': notes,
      'claimedAt': claimedAt == null ? null : Timestamp.fromDate(claimedAt!),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      'createdByUid': createdByUid,
    };
  }
}
