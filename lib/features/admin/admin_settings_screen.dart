import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/app_config.dart';
import '../../providers/config_provider.dart';
import '../../widgets/eid_app_bar.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _coordsCtrl = TextEditingController();
  DateTime? _eidDate;
  DateTime? _gatheringDate;
  bool _hydrated = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _coordsCtrl.dispose();
    super.dispose();
  }

  void _hydrate(AppConfig config) {
    if (_hydrated) return;
    _hydrated = true;
    _nameCtrl.text = config.name;
    _locationCtrl.text = config.location ?? '';
    _coordsCtrl.text = config.locationCoords ?? '';
    _eidDate = config.eidDate;
    _gatheringDate = config.gatheringDate;
    setState(() {});
  }

  Future<void> _pickDate({
    required DateTime? initial,
    required ValueChanged<DateTime?> onPicked,
  }) async {
    final DateTime now = DateTime.now();
    final DateTime first = DateTime(now.year - 1);
    final DateTime last = DateTime(now.year + 3);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: first,
      lastDate: last,
      locale: const Locale('ar'),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final AppConfig current =
          ref.read(appConfigProvider).value ?? AppConfig.empty();
      final AppConfig next = current.copyWith(
        name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        eidDate: _eidDate,
        gatheringDate: _gatheringDate,
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
        locationCoords: _coordsCtrl.text.trim().isEmpty
            ? null
            : _coordsCtrl.text.trim(),
      );
      await ref.read(configServiceProvider).save(next);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الإعدادات.')),
      );
      if (context.canPop()) context.pop();
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
    final AsyncValue<AppConfig> configAsync = ref.watch(appConfigProvider);
    configAsync.whenData(_hydrate);

    return Scaffold(
      appBar: const EidAppBar(title: 'إعدادات اللمَّة'),
      body: configAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: EidColors.gold),
        ),
        error: (Object err, _) => Center(child: Text('خطأ: $err')),
        data: (AppConfig _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            children: <Widget>[
              const _SectionHeader('عام'),
              const SizedBox(height: 10),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'اسم اللمَّة',
                  prefixIcon: Icon(Icons.celebration_outlined),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionHeader('المؤقّتات'),
              const SizedBox(height: 10),
              _DateField(
                label: 'يوم العيد',
                hint: 'يفعّل شاشة التكبيرات والألعاب النارية',
                icon: Icons.brightness_2,
                value: _eidDate,
                onPick: () => _pickDate(
                  initial: _eidDate,
                  onPicked: (DateTime? d) => setState(() => _eidDate = d),
                ),
                onClear: _eidDate == null
                    ? null
                    : () => setState(() => _eidDate = null),
              ),
              const SizedBox(height: 12),
              _DateField(
                label: 'يوم الاستراحة',
                hint: 'يوم اللمَّة العائلية (قد يختلف عن العيد)',
                icon: Icons.event_available,
                value: _gatheringDate,
                onPick: () => _pickDate(
                  initial: _gatheringDate,
                  onPicked: (DateTime? d) =>
                      setState(() => _gatheringDate = d),
                ),
                onClear: _gatheringDate == null
                    ? null
                    : () => setState(() => _gatheringDate = null),
              ),
              const SizedBox(height: 24),
              const _SectionHeader('الموقع'),
              const SizedBox(height: 10),
              TextField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'اسم/عنوان الاستراحة',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _coordsCtrl,
                decoration: const InputDecoration(
                  labelText: 'إحداثيات (lat,lng) — اختياري',
                  hintText: '24.7136,46.6753',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: EidColors.cream,
                      strokeWidth: 2.4,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('حفظ الإعدادات'),
            onPressed: _saving ? null : _save,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: EidColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: EidColors.darkGreen,
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.onPick,
    this.onClear,
  });

  final String label;
  final String hint;
  final IconData icon;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: EidColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: EidColors.divider, width: 0.8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              Icon(icon, color: EidColors.green, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: EidColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value == null
                          ? hint
                          : '${EidDateUtils.formatGregorianAr(value!)}'
                              ' · ${EidDateUtils.formatHijri(value!)}',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: value == null
                            ? EidColors.textSecondary
                            : EidColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: EidColors.textSecondary,
                    size: 18,
                  ),
                  onPressed: onClear,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
