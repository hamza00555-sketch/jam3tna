import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryQuota {
  final int count;
  final String sectionKey; // "men" | "women" | "shared"

  const CategoryQuota({required this.count, required this.sectionKey});

  Map<String, dynamic> toMap() =>
      <String, dynamic>{'count': count, 'section': sectionKey};

  factory CategoryQuota.fromMap(Map<String, dynamic> map) {
    return CategoryQuota(
      count: (map['count'] as int?) ?? 0,
      sectionKey: (map['section'] as String?) ?? 'shared',
    );
  }
}

class AppConfig {
  final String name;

  /// تاريخ يوم العيد (لتشغيل التكبيرات والألعاب النارية).
  final DateTime? eidDate;

  /// تاريخ يوم الاستراحة العائلية (مختلف عن يوم العيد غالباً).
  final DateTime? gatheringDate;

  final String? location;

  /// إحداثيات الاستراحة "lat,lng" لرابط Maps.
  final String? locationCoords;

  final List<String> admins;
  final String currency;

  /// مفتاح الفئة → كوتا (عدد + قسم).
  final Map<String, CategoryQuota> categoriesConfig;

  const AppConfig({
    required this.name,
    required this.admins,
    required this.currency,
    required this.categoriesConfig,
    this.eidDate,
    this.gatheringDate,
    this.location,
    this.locationCoords,
  });

  factory AppConfig.empty() => const AppConfig(
        name: 'جمعتنا — عيد الأضحى',
        admins: <String>[],
        currency: 'SAR',
        categoriesConfig: <String, CategoryQuota>{},
      );

  factory AppConfig.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    final Map<String, dynamic> rawCats =
        (data['categoriesConfig'] as Map<String, dynamic>?) ??
            <String, dynamic>{};
    // backward-compat: نقبل eventDate القديم كـ gatheringDate.
    final DateTime? legacyEvent =
        (data['eventDate'] as Timestamp?)?.toDate();
    return AppConfig(
      name: (data['name'] as String?) ?? 'جمعتنا',
      eidDate: (data['eidDate'] as Timestamp?)?.toDate(),
      gatheringDate:
          (data['gatheringDate'] as Timestamp?)?.toDate() ?? legacyEvent,
      location: data['location'] as String?,
      locationCoords: data['locationCoords'] as String?,
      admins: ((data['admins'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic e) => e.toString())
          .toList(),
      currency: (data['currency'] as String?) ?? 'SAR',
      categoriesConfig: rawCats.map(
        (String key, dynamic value) => MapEntry<String, CategoryQuota>(
          key,
          CategoryQuota.fromMap(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'eidDate': eidDate == null ? null : Timestamp.fromDate(eidDate!),
      'gatheringDate':
          gatheringDate == null ? null : Timestamp.fromDate(gatheringDate!),
      'location': location,
      'locationCoords': locationCoords,
      'admins': admins,
      'currency': currency,
      'categoriesConfig': categoriesConfig.map(
          (String k, CategoryQuota v) => MapEntry<String, dynamic>(k, v.toMap())),
    };
  }

  AppConfig copyWith({
    String? name,
    DateTime? eidDate,
    DateTime? gatheringDate,
    String? location,
    String? locationCoords,
    List<String>? admins,
    String? currency,
    Map<String, CategoryQuota>? categoriesConfig,
  }) {
    return AppConfig(
      name: name ?? this.name,
      eidDate: eidDate ?? this.eidDate,
      gatheringDate: gatheringDate ?? this.gatheringDate,
      location: location ?? this.location,
      locationCoords: locationCoords ?? this.locationCoords,
      admins: admins ?? this.admins,
      currency: currency ?? this.currency,
      categoriesConfig: categoriesConfig ?? this.categoriesConfig,
    );
  }
}
