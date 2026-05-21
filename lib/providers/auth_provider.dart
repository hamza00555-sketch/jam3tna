import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';

final authServiceProvider = Provider<AuthService>((Ref ref) {
  return AuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((Ref ref) {
  return FirestoreService();
});

/// يبثّ تغييرات حالة المصادقة (Firebase User أو null).
final authStateChangesProvider = StreamProvider<User?>((Ref ref) {
  final AuthService auth = ref.watch(authServiceProvider);
  return auth.authStateChanges();
});
