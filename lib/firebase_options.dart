// هذا الملف placeholder سيُستبدل تلقائياً بمخرجات `flutterfire configure`.
// لا تعدّله يدوياً. شغّل من جذر المشروع:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=<your-firebase-project-id>
//
// سيُولّد الـ CLI ملفاً حقيقياً يحوي مفاتيح API لكل منصة (Android/iOS/Web).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'firebase_options.dart غير مُعدّ بعد. شغّل `flutterfire configure` أولاً.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'firebase_options.dart غير مُعدّ بعد. شغّل `flutterfire configure` أولاً.',
        );
    }
  }
}
