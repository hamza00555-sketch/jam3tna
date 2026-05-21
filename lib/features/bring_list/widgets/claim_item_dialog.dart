import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/item.dart';

class ClaimItemResult {
  final String itemName;
  final String? notes;
  const ClaimItemResult({required this.itemName, this.notes});
}

class ClaimItemDialog extends StatefulWidget {
  const ClaimItemDialog({
    super.key,
    required this.categoryLabel,
    this.initialItem,
    this.initialNotes,
    this.title,
  });

  final String categoryLabel;
  final String? initialItem;
  final String? initialNotes;
  final String? title;

  static Future<ClaimItemResult?> show(
    BuildContext context, {
    required String categoryLabel,
    String? initialItem,
    String? initialNotes,
    String? title,
  }) {
    return showDialog<ClaimItemResult>(
      context: context,
      builder: (BuildContext ctx) => ClaimItemDialog(
        categoryLabel: categoryLabel,
        initialItem: initialItem,
        initialNotes: initialNotes,
        title: title,
      ),
    );
  }

  static Future<ClaimItemResult?> showForItem(
    BuildContext context, {
    required Item item,
    required String categoryLabel,
  }) {
    return show(
      context,
      categoryLabel: categoryLabel,
      initialItem: item.itemName,
      initialNotes: item.notes,
      title: 'تعديل البند',
    );
  }

  @override
  State<ClaimItemDialog> createState() => _ClaimItemDialogState();
}

class _ClaimItemDialogState extends State<ClaimItemDialog> {
  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.initialItem ?? '');
  late final TextEditingController _notesCtrl =
      TextEditingController(text: widget.initialNotes ?? '');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title ?? 'حجز بند'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.categoryLabel,
              style: const TextStyle(
                color: EidColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'اسم البند',
                hintText: 'مثلاً: كنافة بالقشطة',
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
                hintText: 'حار، نباتي، عدد القطع...',
              ),
            ),
          ],
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
              ClaimItemResult(
                itemName: _nameCtrl.text.trim(),
                notes: _notesCtrl.text.trim().isEmpty
                    ? null
                    : _notesCtrl.text.trim(),
              ),
            );
          },
          child: const Text('تأكيد'),
        ),
      ],
    );
  }
}
