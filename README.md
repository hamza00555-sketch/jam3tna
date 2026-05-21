# جمعتنا

تطبيق Flutter عائلي لتنسيق رحلة استراحة يوم العيد لمجموعة من ١٢ شخصاً
(٤ رجال + ٤ نساء + ٤ أطفال). يقسم الواجهات إلى قسم رجال/نساء ويغطي:
قائمة الجلب، المصاريف، معرض الصور، Voice Notes، تصويت المسبح، جدول اليوم.

## الحالة الحالية: M1 — التهيئة + المصادقة

تم إنجاز:
- إعداد Flutter + Firebase (Auth/Firestore/Storage/Messaging).
- Theme عيدي (أخضر زمردي + ذهبي + عاجي + خط Cairo).
- Routing تصريحي عبر `go_router` مع حراس مصادقة.
- شاشات: Splash, Login, Signup, SectionPicker, Home (placeholder).
- خدمات: AuthService + FirestoreService.
- Riverpod providers للمصادقة والمستخدم الحالي.

## التشغيل محلياً (مرّة واحدة)

### المتطلبات

- Flutter SDK 3.27+ (https://docs.flutter.dev/get-started/install)
- Android Studio أو Xcode مع emulator/simulator.
- حساب Firebase.

### الخطوات

١. **استنساخ المشروع**:

```bash
git clone https://github.com/hamza00555-sketch/jam3tna.git
cd jam3tna
```

٢. **إنشاء مشروع Firebase**:

- اذهب إلى https://console.firebase.google.com/
- أنشئ مشروعاً باسم `jam3tna` (أو ما تشاء).
- فعّل الخدمات التالية:
  - **Authentication** → Sign-in method → Email/Password (مُفعّل).
  - **Cloud Firestore** → ابدأ في وضع Production (سنضبط Rules لاحقاً).
  - **Storage** → ابدأ في وضع Production.
  - **Cloud Messaging** (تلقائي).

٣. **ربط Firebase بـ Flutter**:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<firebase-project-id>
```

هذا يولّد `lib/firebase_options.dart` تلقائياً ويستبدل الـ placeholder.

٤. **تثبيت الـ dependencies**:

```bash
flutter pub get
```

٥. **التشغيل**:

```bash
flutter run
```

### Firestore Rules مؤقتة (للتطوير فقط)

في Firebase Console → Firestore → Rules، استخدم هذه القواعد للتطوير:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

⚠️ هذه القواعد مفتوحة لأي مستخدم مسجّل. ستُستبدل بقواعد صارمة في M7.

### إعداد الأدمن

١. سجّل أول مستخدم من شاشة Signup داخل التطبيق.
٢. افتح Firestore Console → `users/{uid}` للمستخدم.
٣. غيّر `role` من `"member"` إلى `"admin"`.
٤. أضِف uid للمستخدم في `config/app.admins` (إنشاء الوثيقة يدوياً إن لم تكن موجودة).

## هيكل المشروع

```
lib/
├── main.dart                   # bootstrap + Firebase.initializeApp
├── app.dart                    # MaterialApp.router + Theme
├── firebase_options.dart       # توّلده flutterfire configure
├── core/
│   ├── theme/                  # alpha + typography + theme
│   └── routing/                # go_router config + auth guards
├── models/                     # AppUser + enums (manual, no freezed)
├── services/
│   ├── auth_service.dart       # Firebase Auth wrapper
│   └── firestore_service.dart  # مرجع users + إنشاء وثيقة
├── providers/                  # Riverpod providers
└── features/
    ├── auth/                   # Splash, Login, Signup, SectionPicker
    └── home/                   # Home placeholder
```

## الخارطة (Roadmap)

- ✅ **M1**: التهيئة + Theme + Routing + Auth + SectionPicker.
- ⏳ **M2**: Home grid + Bring List (هجين) + إدارة الفئات + transactions.
- ⏳ **M3**: المصاريف + التقسيم + رفع الفواتير.
- ⏳ **M4**: معرض الصور + برواز عيدي.
- ⏳ **M5**: تصويت المسبح + الجدول + الإعدادات.
- ⏳ **M6**: Voice Notes + قناة نصية + read receipts.
- ⏳ **M7**: Security Rules + Cloud Functions + تلميع + توزيع.
