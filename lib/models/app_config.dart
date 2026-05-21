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
  final DateTime? eventDate;
  final String? location;
  final List<String> admins;
  final String currency;

  /// مفتاح الفئة → كوتا (عدد + قسم).
  final Map<String, CategoryQuota> categoriesConfig;

  const AppConfig({
    required this.name,
    required this.admins,
    required this.currency,
    required this.categoriesConfig,
    this.eventDate,
    this.location,
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
    return AppConfig(
      name: (data['name'] as String?) ?? 'جمعتنا',
      eventDate: (data['eventDate'] as Timestamp?)?.toDate(),
      location: data['location'] as String?,
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
      'eventDate': eventDate == null ? null : Timestamp.fromDate(eventDate!),
      'location': location,
      'admins': admins,
      'currency': currency,
      'categoriesConfig': categoriesConfig
          .map((String k, CategoryQuota v) => MapEntry<String, dynamic>(k, v.toMap())),
    };
  }
}
