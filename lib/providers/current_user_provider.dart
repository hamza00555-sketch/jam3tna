import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import 'auth_provider.dart';

/// يبثّ وثيقة المستخدم الحالي من Firestore (أو null إن لم يكن مسجّلاً).
/// يربط حالة Firebase Auth بـ Firestore document.
final currentUserProvider = StreamProvider<AppUser?>((Ref ref) {
  final AsyncValue<User?> authAsync = ref.watch(authStateChangesProvider);

  return authAsync.when(
    data: (User? user) {
      if (user == null) return Stream<AppUser?>.value(null);
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.watchUser(user.uid);
    },
    loading: () => const Stream<AppUser?>.empty(),
    error: (Object _, StackTrace __) => Stream<AppUser?>.value(null),
  );
});
