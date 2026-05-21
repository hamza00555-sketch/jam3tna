import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/routing/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/app_config.dart';
import '../../models/app_user.dart';
import '../../models/item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/config_provider.dart';
import '../../providers/current_user_provider.dart';
import '../../providers/items_provider.dart';
import '../../widgets/eid_app_bar.dart';
import 'widgets/eid_countdown_card.dart';
import 'widgets/feature_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _autoOpenChecked = false;

  Future<void> _maybeAutoOpenEidDay(DateTime? eidDate) async {
    if (_autoOpenChecked) return;
    _autoOpenChecked = true;
    if (eidDate == null || !EidDateUtils.isToday(eidDate)) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String todayKey =
        '${eidDate.year}-${eidDate.month}-${eidDate.day}';
    final String? shownFor = prefs.getString('eid_auto_shown_for');
    if (shownFor == todayKey) return;
    await prefs.setString('eid_auto_shown_for', todayKey);
    if (!mounted) return;
    // ندع الـ frame يكتمل قبل التنقّل.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.push(AppRoutes.eidDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppUser?> userAsync = ref.watch(currentUserProvider);
    final AsyncValue<AppConfig> configAsync = ref.watch(appConfigProvider);
    final AsyncValue<List<Item>> itemsAsync = ref.watch(allItemsProvider);

    final AppConfig config = configAsync.value ?? AppConfig.empty();
    _maybeAutoOpenEidDay(config.eidDate);

    return Scaffold(
      appBar: EidAppBar(
        title: 'جمعتنا',
        actions: <Widget>[
          if (userAsync.value?.isAdmin ?? false)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'إعدادات اللمَّة',
              onPressed: () => context.push(AppRoutes.adminSettings),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => _confirmLogout(context, ref),
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
          final List<Item> allItems = itemsAsync.value ?? <Item>[];
          final int myClaimedCount =
              allItems.where((Item i) => i.claimedByUid == user.uid).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                EidCountdownCard(
                  eidDate: config.eidDate,
                  gatheringDate: config.gatheringDate,
                  displayName: user.displayName,
                  sectionLabel: user.section?.labelAr ?? '—',
                  onTapEidDay: () => context.push(AppRoutes.eidDay),
                ),
                const SizedBox(height: 20),
                if (myClaimedCount > 0) ...<Widget>[
                  _MyItemsBanner(
                    count: myClaimedCount,
                    onTap: () => context.push(AppRoutes.myItems),
                  ),
                  const SizedBox(height: 16),
                ],
                const _SectionHeader(text: 'ميزات اللمَّة'),
                const SizedBox(height: 12),
                const _FeaturesGrid(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد فعلاً تسجيل الخروج؟'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authServiceProvider).signOut();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: EidColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: EidColors.darkGreen,
          ),
        ),
      ],
    );
  }
}

class _MyItemsBanner extends StatelessWidget {
  const _MyItemsBanner({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: EidColors.gold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: EidColors.gold.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.shopping_basket_outlined,
                color: EidColors.darkGreen,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'عليك جلب $count بند${_arSuffix(count)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: EidColors.darkGreen,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_left,
                color: EidColors.darkGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _arSuffix(int n) {
    if (n == 1) return 'اً';
    if (n == 2) return 'ين';
    return '';
  }
}

class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.05,
      children: <Widget>[
        FeatureCard(
          title: 'قائمة الجلب',
          icon: Icons.checklist_rtl,
          color: EidColors.green,
          onTap: () => context.push(AppRoutes.bringList),
        ),
        FeatureCard(
          title: 'المصاريف',
          icon: Icons.account_balance_wallet_outlined,
          color: EidColors.gold,
          onTap: () => context.push(AppRoutes.expenses),
          enabled: false,
        ),
        FeatureCard(
          title: 'الصور',
          icon: Icons.photo_library_outlined,
          color: EidColors.accentRose,
          onTap: () => context.push(AppRoutes.gallery),
          enabled: false,
        ),
        FeatureCard(
          title: 'الأصوات',
          icon: Icons.mic_none_outlined,
          color: EidColors.darkGreen,
          onTap: () => context.push(AppRoutes.voiceNotes),
          enabled: false,
        ),
        FeatureCard(
          title: 'تصويت المسبح',
          icon: Icons.pool_outlined,
          color: EidColors.green,
          onTap: () => context.push(AppRoutes.pool),
          enabled: false,
        ),
        FeatureCard(
          title: 'جدول اليوم',
          icon: Icons.schedule,
          color: EidColors.gold,
          onTap: () => context.push(AppRoutes.schedule),
          enabled: false,
        ),
      ],
    );
  }
}
