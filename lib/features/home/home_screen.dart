import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/current_user_provider.dart';
import '../../widgets/eid_app_bar.dart';

/// Placeholder لـ M1 — سيُستبدل ببطاقات الميزات في M2.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: EidAppBar(
        title: 'جمعتنا',
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: EidColors.gold),
        ),
        error: (Object err, _) => Center(child: Text('خطأ: $err')),
        data: (AppUser? user) {
          if (user == null) {
            return const Center(child: Text('لا توجد بيانات.'));
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Row(
                          children: <Widget>[
                            Icon(Icons.brightness_2, color: EidColors.gold),
                            SizedBox(width: 8),
                            Text(
                              'كل عام وأنتم بخير',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: EidColors.darkGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'مرحباً ${user.displayName}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'القسم: ${user.section?.labelAr ?? "—"}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: EidColors.textSecondary,
                          ),
                        ),
                        Text(
                          'الدور: ${user.role.labelAr}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: EidColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.construction, size: 40, color: EidColors.gold),
                        SizedBox(height: 12),
                        Text(
                          'الميزات قادمة في M2',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: EidColors.darkGreen,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'قائمة الجلب · المصاريف · الصور · الأصوات · المسبح · الجدول',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: EidColors.textSecondary,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
