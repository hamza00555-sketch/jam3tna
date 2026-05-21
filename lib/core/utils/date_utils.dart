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
