/// Enums للتطبيق — كل enum له `key` للتخزين و `labelAr` للعرض.

enum UserSection {
  men('men', 'قسم الرجال'),
  women('women', 'قسم النساء');

  const UserSection(this.key, this.labelAr);
  final String key;
  final String labelAr;

  static UserSection? fromKey(String? key) {
    if (key == null) return null;
    for (final UserSection s in UserSection.values) {
      if (s.key == key) return s;
    }
    return null;
  }
}

enum UserRole {
  admin('admin', 'مشرف'),
  member('member', 'عضو');

  const UserRole(this.key, this.labelAr);
  final String key;
  final String labelAr;

  static UserRole fromKey(String? key) {
    if (key == null) return UserRole.member;
    for (final UserRole r in UserRole.values) {
      if (r.key == key) return r;
    }
    return UserRole.member;
  }
}

enum ItemCategory {
  mainDishes('mainDishes', 'أطباق رئيسية'),
  desserts('desserts', 'حلويات'),
  appetizers('appetizers', 'مقبلات'),
  hotDrinks('hotDrinks', 'مشروبات ساخنة'),
  coldDrinks('coldDrinks', 'مشروبات باردة'),
  fruits('fruits', 'فواكه'),
  iceCream('iceCream', 'آيس كريم'),
  bread('bread', 'خبز'),
  sides('sides', 'أطباق جانبية'),
  logistics('logistics', 'لوجستيات'),
  other('other', 'أخرى');

  const ItemCategory(this.key, this.labelAr);
  final String key;
  final String labelAr;

  static ItemCategory fromKey(String? key) {
    if (key == null) return ItemCategory.other;
    for (final ItemCategory c in ItemCategory.values) {
      if (c.key == key) return c;
    }
    return ItemCategory.other;
  }
}

/// قسم البند في Bring List: men / women / shared.
enum ItemSection {
  men('men', 'قسم الرجال'),
  women('women', 'قسم النساء'),
  shared('shared', 'مشترك');

  const ItemSection(this.key, this.labelAr);
  final String key;
  final String labelAr;

  static ItemSection fromKey(String? key) {
    if (key == null) return ItemSection.shared;
    for (final ItemSection s in ItemSection.values) {
      if (s.key == key) return s;
    }
    return ItemSection.shared;
  }
}

enum SplitMode {
  allAdults('all_adults', 'جميع البالغين'),
  menOnly('men_only', 'الرجال فقط'),
  womenOnly('women_only', 'النساء فقط'),
  custom('custom', 'مخصّص');

  const SplitMode(this.key, this.labelAr);
  final String key;
  final String labelAr;

  static SplitMode fromKey(String? key) {
    if (key == null) return SplitMode.allAdults;
    for (final SplitMode s in SplitMode.values) {
      if (s.key == key) return s;
    }
    return SplitMode.allAdults;
  }
}

enum VoiceChannel {
  men('men', 'قناة الرجال'),
  women('women', 'قناة النساء'),
  all('all', 'القناة العامة');

  const VoiceChannel(this.key, this.labelAr);
  final String key;
  final String labelAr;

  static VoiceChannel fromKey(String? key) {
    if (key == null) return VoiceChannel.all;
    for (final VoiceChannel c in VoiceChannel.values) {
      if (c.key == key) return c;
    }
    return VoiceChannel.all;
  }
}
