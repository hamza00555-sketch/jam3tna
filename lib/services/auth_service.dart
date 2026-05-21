import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);
    return cred;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  String mapErrorToArabic(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'صيغة البريد الإلكتروني غير صحيحة.';
        case 'user-disabled':
          return 'هذا الحساب موقوف.';
        case 'user-not-found':
          return 'لا يوجد حساب بهذا البريد.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'البريد أو كلمة المرور غير صحيحة.';
        case 'email-already-in-use':
          return 'هذا البريد مستخدم بالفعل.';
        case 'weak-password':
          return 'كلمة المرور ضعيفة. استخدم ٦ أحرف على الأقل.';
        case 'network-request-failed':
          return 'لا يوجد اتصال بالإنترنت.';
        default:
          return error.message ?? 'حدث خطأ غير متوقع.';
      }
    }
    return 'حدث خطأ غير متوقع.';
  }
}
