import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class EidDateUtils {
  EidDateUtils._();

  static int daysUntil(DateTime? target) {
    if (target == null) return 0;
    final DateTime now = DateTime.now();
    final DateTime t = DateTime(target.year, target.month, target.day);
    final DateTime n = DateTime(now.year, now.month, now.day);
    return t.difference(n).inDays;
  }

  /// true إذا [target] هو اليوم نفسه (حسب التاريخ المحلي).
  static bool isToday(DateTime? target) {
    if (target == null) return false;
    return daysUntil(target) == 0;
  }

  /// عبارة عربية للعد التنازلي. مثل: "باقي ٦ أيام"، "اليوم"، "غداً".
  static String countdownText({
    required DateTime? target,
    String emptyText = 'لم يُحدّد بعد',
    String todayText = 'اليوم',
    String passedText = 'انتهى',
  }) {
    if (target == null) return emptyText;
    final int d = daysUntil(target);
    if (d < 0) return passedText;
    if (d == 0) return todayText;
    if (d == 1) return 'غداً';
    if (d == 2) return 'بعد يومين';
    if (d <= 10) return 'باقي $d أيام';
    return 'باقي $d يوماً';
  }

  static String formatGregorianAr(DateTime date) {
    final DateFormat fmt = DateFormat('EEEE d MMMM y', 'ar');
    return fmt.format(date);
  }

  static String formatHijri(DateTime date) {
    final HijriCalendar h = HijriCalendar.fromDate(date);
    return '${h.hDay} ${h.longMonthName} ${h.hYear}';
  }

  static String todayHijri() {
    return formatHijri(DateTime.now());
  }
}
