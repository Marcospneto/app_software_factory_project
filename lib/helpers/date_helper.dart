import 'package:intl/intl.dart';
import 'package:meu_tempo/helpers/date_time_extension.dart';

class DateHelper {
  static DateTime get today => DateTime.now().toDateOnly();

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static DateTime parseDate(String dateString) {
    return DateFormat('dd/MM/yyyy').parse(dateString);
  }

  static String formatDateSave(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime parseDateSaved(String dateString) {
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }

  static DateTime getFirstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7)).toDateOnly();
  }

  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
}
