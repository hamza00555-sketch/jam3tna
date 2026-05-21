import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';

class AddFreeItemResult {
  final ItemCategory category;
  final ItemSection section;
  final String itemName;
  final String? notes;

  const AddFreeItemResult({
    required this.category,
    required this.section,
    required this.itemName,
    this.notes,
  });
}

class AddFreeItemDialog extends StatefulWidget {
  const AddFreeItemDialog({
    super.key,
    required this.defaultSection,
    this.defaultCategory,
  });

  final ItemSection defaultSection;
  final ItemCategory? defaultCategory;

  static Future<AddFreeItemResult?> show(
    BuildContext context, {
    required ItemSection defaultSection,
    ItemCategory? defaultCategory,
  }) {
    return showDialog<AddFreeItemResult>(
      context: context,
      builder: (BuildContext ctx) => AddFreeItemDialog(
        defaultSection: defaultSection,
        defaultCategory: defaultCategory,
      ),
    );
  }

  @override
  State<AddFreeItemDialog> createState() => _AddFreeItemDialogState();
}

class _AddFreeItemDialogState extends State<AddFreeItemDialog> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ItemCategory _category =
      widget.defaultCategory ?? ItemCategory.mainDishes;
  late ItemSection _section = widget.defaultSection;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة بند إضافي'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'البند الإضافي يُضاف خارج الكوتا المحدّدة من المشرف، ويُحجز باسمك مباشرة.',
                style: TextStyle(
                  fontSize: 12,
                  color: EidColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ItemCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: ItemCategory.values
                    .map((ItemCategory c) => DropdownMenuItem<ItemCategory>(
                          value: c,
                          child: Text(c.labelAr),
                        ))
                    .toList(),
                onChanged: (ItemCategory? v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ItemSection>(
                initialValue: _section,
                decoration: const InputDecoration(
                  labelText: 'القسم',
                  prefixIcon: Icon(Icons.groups_outlined),
                ),
                items: ItemSection.values
                    .map((ItemSection s) => DropdownMenuItem<ItemSection>(
                          value: s,
                          child: Text(s.labelAr),
                        ))
                    .toList(),
                onChanged: (ItemSection? v) {
                  if (v != null) setState(() => _section = v);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'اسم البند',
                  hintText: 'مثلاً: قطايف بالجوز',
                ),
                validator: (String? v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'أدخل اسم البند.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              AddFreeItemResult(
                category: _category,
                section: _section,
                itemName: _nameCtrl.text.trim(),
                notes: _notesCtrl.text.trim().isEmpty
                    ? null
                    : _notesCtrl.text.trim(),
              ),
            );
          },
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
