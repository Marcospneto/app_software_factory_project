// datetime_extensions.dart
extension DateTimeExtensions on DateTime {
  /// Retorna apenas a parte da data (remove horas, minutos, etc.)
  DateTime toDateOnly() {
    return DateTime(this.year, this.month, this.day);
  }

  String formatTime() {
    return '${this.hour.toString().padLeft(2, '0')}:${this.minute.toString().padLeft(2, '0')}';
  }
}