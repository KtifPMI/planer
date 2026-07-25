import 'package:intl/intl.dart';

String formatCurrency(double amount, {String symbol = '₽'}) {
  final formatter = NumberFormat('#,##0', 'ru_RU');
  return '${formatter.format(amount)} $symbol';
}

String formatPercent(double value) {
  return '${(value * 100).toStringAsFixed(1)}%';
}

String formatDate(DateTime date, {String pattern = 'dd.MM.yyyy'}) {
  return DateFormat(pattern, 'ru_RU').format(date);
}

String formatDateShort(DateTime date) {
  return DateFormat('d MMM', 'ru_RU').format(date);
}

String formatMonthYear(DateTime date) {
  return DateFormat('MMMM yyyy', 'ru_RU').format(date);
}

DateTime startOfWeek(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}

DateTime endOfWeek(DateTime date) {
  return startOfWeek(date).add(const Duration(days: 6));
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

int daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}
