import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';

class SectionPickerScreen extends ConsumerStatefulWidget {
  const SectionPickerScreen({super.key});

  @override
  ConsumerState<SectionPickerScreen> createState() =>
      _SectionPickerScreenState();
}

class _SectionPickerScreenState extends ConsumerState<SectionPickerScreen> {
  bool _saving = false;

  Future<void> _pick(UserSection section) async {
    final User? user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(firestoreServiceProvider).setUserSection(
            uid: user.uid,
            section: section,
          );
      // التحويل يتولاه GoRouter redirect تلقائياً → home.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر الحفظ: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 24),
              const Text(
                'اختر قسمك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: EidColors.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'حدّد القسم الذي ستشارك فيه — تستطيع تغييره لاحقاً من الإعدادات.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: EidColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _SectionCard(
                        section: UserSection.men,
                        icon: Icons.male,
                        accent: EidColors.green,
                        onTap: _saving ? null : () => _pick(UserSection.men),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SectionCard(
                        section: UserSection.women,
                        icon: Icons.female,
                        accent: EidColors.accentRose,
                        onTap: _saving ? null : () => _pick(UserSection.women),
                      ),
                    ),
                  ],
                ),
              ),
              if (_saving) ...<Widget>[
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(color: EidColors.gold),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final UserSection section;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: EidColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 42, color: accent),
              ),
              const SizedBox(height: 20),
              Text(
                section.labelAr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
