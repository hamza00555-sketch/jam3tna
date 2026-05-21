import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/section_picker_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/current_user_provider.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((Ref ref) {
  final _AuthRefreshNotifier refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      final AsyncValue<User?> authAsync = ref.read(authStateChangesProvider);
      final AsyncValue<AppUser?> userAsync = ref.read(currentUserProvider);

      // أثناء التحميل الأول، أبقِ المستخدم على Splash.
      if (authAsync.isLoading) {
        return state.matchedLocation == AppRoutes.splash
            ? null
            : AppRoutes.splash;
      }

      final User? firebaseUser = authAsync.value;
      final String location = state.matchedLocation;
      final bool atAuth = location == AppRoutes.login ||
          location == AppRoutes.signup;
      final bool atSplash = location == AppRoutes.splash;

      // غير مسجّل.
      if (firebaseUser == null) {
        if (atAuth) return null;
        return AppRoutes.login;
      }

      // مسجّل لكن وثيقة Firestore لم تصل بعد.
      if (userAsync.isLoading || !userAsync.hasValue) {
        return atSplash ? null : AppRoutes.splash;
      }

      final AppUser? appUser = userAsync.value;

      // مسجّل لكن لا توجد وثيقة (حالة نادرة) → splash.
      if (appUser == null) {
        return atSplash ? null : AppRoutes.splash;
      }

      // مسجّل بلا قسم → SectionPicker.
      if (!appUser.hasSection) {
        if (location == AppRoutes.sectionPicker) return null;
        return AppRoutes.sectionPicker;
      }

      // مسجّل وله قسم → home.
      if (atAuth || atSplash || location == AppRoutes.sectionPicker) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (BuildContext context, GoRouterState state) =>
            const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.sectionPicker,
        builder: (BuildContext context, GoRouterState state) =>
            const SectionPickerScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
    ],
  );
});

/// يستمع لتغيّر `authStateChangesProvider` و `currentUserProvider` ويُخبر GoRouter بإعادة التقييم.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _authSub = _ref.listen<AsyncValue<User?>>(
      authStateChangesProvider,
      (AsyncValue<User?>? _, AsyncValue<User?> __) => notifyListeners(),
      fireImmediately: false,
    );
    _userSub = _ref.listen<AsyncValue<AppUser?>>(
      currentUserProvider,
      (AsyncValue<AppUser?>? _, AsyncValue<AppUser?> __) => notifyListeners(),
      fireImmediately: false,
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<User?>> _authSub;
  late final ProviderSubscription<AsyncValue<AppUser?>> _userSub;

  @override
  void dispose() {
    _authSub.close();
    _userSub.close();
    super.dispose();
  }
}
