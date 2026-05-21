import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/app_config.dart';
import '../../models/enums.dart';
import '../../providers/config_provider.dart';
import '../../widgets/eid_app_bar.dart';

class AdminCategoriesScreen extends ConsumerStatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  ConsumerState<AdminCategoriesScreen> createState() =>
      _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends ConsumerState<AdminCategoriesScreen> {
  final Map<ItemCategory, TextEditingController> _counts =
      <ItemCategory, TextEditingController>{};
  final Map<ItemCategory, ItemSection> _sections =
      <ItemCategory, ItemSection>{};
  bool _loadedInitial = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final ItemCategory c in ItemCategory.values) {
      _counts[c] = TextEditingController(text: '0');
      _sections[c] = ItemSection.shared;
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _counts.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrateFromConfig(AppConfig config) {
    if (_loadedInitial) return;
    _loadedInitial = true;
    config.categoriesConfig.forEach((String key, CategoryQuota q) {
      final ItemCategory cat = ItemCategory.fromKey(key);
      _counts[cat]!.text = q.count.toString();
      _sections[cat] = ItemSection.fromKey(q.sectionKey);
    });
    setState(() {});
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final Map<String, CategoryQuota> newConfig = <String, CategoryQuota>{};
      for (final ItemCategory c in ItemCategory.values) {
        final int count =
            int.tryParse(_counts[c]!.text.trim()) ?? 0;
        if (count > 0) {
          newConfig[c.key] = CategoryQuota(
            count: count,
            sectionKey: _sections[c]!.key,
          );
        }
      }
      await ref
          .read(configServiceProvider)
          .updateCategories(categoriesConfig: newConfig);
      await ref
          .read(itemsBootstrapServiceProvider)
          .applyConfig(newConfig);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الفئات وتوليد البنود.')),
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
    configAsync.whenData(_hydrateFromConfig);

    return Scaffold(
      appBar: const EidAppBar(title: 'إعدادات الفئات'),
      body: configAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: EidColors.gold),
        ),
        error: (Object err, _) => Center(child: Text('خطأ: $err')),
        data: (AppConfig _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: EidColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: EidColors.gold.withValues(alpha: 0.45),
                  ),
                ),
                child: const Row(
                  children: <Widget>[
                    Icon(
                      Icons.lightbulb_outline,
                      color: EidColors.darkGreen,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'حدّد عدد البنود لكل فئة والقسم المناسب. الأعضاء '
                        'سيستطيعون إضافة بنود إضافية خارج هذه الأعداد.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: EidColors.darkGreen,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...ItemCategory.values
                  .map((ItemCategory c) => _CategoryRow(
                        category: c,
                        countCtrl: _counts[c]!,
                        section: _sections[c]!,
                        onSectionChanged: (ItemSection s) =>
                            setState(() => _sections[c] = s),
                      )),
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
            label: const Text('حفظ وتوليد البنود'),
            onPressed: _saving ? null : _save,
          ),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.countCtrl,
    required this.section,
    required this.onSectionChanged,
  });

  final ItemCategory category;
  final TextEditingController countCtrl;
  final ItemSection section;
  final ValueChanged<ItemSection> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EidColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EidColors.divider, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            category.labelAr,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: EidColors.darkGreen,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              SizedBox(
                width: 90,
                child: TextField(
                  controller: countCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'العدد',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<ItemSection>(
                  segments: const <ButtonSegment<ItemSection>>[
                    ButtonSegment<ItemSection>(
                      value: ItemSection.shared,
                      label: Text('مشترك'),
                    ),
                    ButtonSegment<ItemSection>(
                      value: ItemSection.men,
                      label: Text('رجال'),
                    ),
                    ButtonSegment<ItemSection>(
                      value: ItemSection.women,
                      label: Text('نساء'),
                    ),
                  ],
                  selected: <ItemSection>{section},
                  onSelectionChanged: (Set<ItemSection> s) {
                    if (s.isNotEmpty) onSectionChanged(s.first);
                  },
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
