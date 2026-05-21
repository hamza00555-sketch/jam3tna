import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/enums.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection('users');

  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      _usersCol.doc(uid);

  Stream<AppUser?> watchUser(String uid) {
    return userDoc(uid).snapshots().map((DocumentSnapshot<Map<String, dynamic>> snap) {
      if (!snap.exists) return null;
      return AppUser.fromFirestore(snap);
    });
  }

  Future<AppUser?> getUser(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snap = await userDoc(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromFirestore(snap);
  }

  /// تُستدعى بعد signup مباشرة. تنشئ وثيقة المستخدم بدون section
  /// (المستخدم يختاره من SectionPickerScreen).
  Future<void> createUserDocument({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref = userDoc(uid);
    final DocumentSnapshot<Map<String, dynamic>> existing = await ref.get();
    if (existing.exists) return;

    await ref.set(<String, dynamic>{
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'section': null,
      'role': UserRole.member.key,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setUserSection({
    required String uid,
    required UserSection section,
  }) {
    return userDoc(uid).update(<String, Object?>{
      'section': section.key,
    });
  }

  Future<void> updateFcmToken({
    required String uid,
    required String token,
  }) {
    return userDoc(uid).update(<String, Object?>{
      'fcmToken': token,
    });
  }
}
