import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_config.dart';

class ConfigService {
  ConfigService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection('config').doc('app');

  Stream<AppConfig> watch() {
    return _doc.snapshots().map((DocumentSnapshot<Map<String, dynamic>> snap) {
      if (!snap.exists) return AppConfig.empty();
      return AppConfig.fromFirestore(snap);
    });
  }

  Future<AppConfig> get() async {
    final DocumentSnapshot<Map<String, dynamic>> snap = await _doc.get();
    if (!snap.exists) return AppConfig.empty();
    return AppConfig.fromFirestore(snap);
  }

  Future<void> save(AppConfig config) {
    return _doc.set(config.toMap(), SetOptions(merge: true));
  }

  Future<void> updateCategories({
    required Map<String, CategoryQuota> categoriesConfig,
  }) {
    final Map<String, dynamic> mapped = categoriesConfig.map(
      (String k, CategoryQuota v) =>
          MapEntry<String, dynamic>(k, v.toMap()),
    );
    return _doc.set(
      <String, dynamic>{'categoriesConfig': mapped},
      SetOptions(merge: true),
    );
  }
}
