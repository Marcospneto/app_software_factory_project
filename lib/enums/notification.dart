enum NotificationEnum {
  NO_NOTIFICATION(1, 'Sem Notificação', 0),
  TEN_MINUTES(2, '10 minutos', 10),
  THIRTY_MINUTES(3, '30 minutos', 30),
  THREE_HOURS(4, '3 horas', 180);

  final int code;
  final String message;
  final int minutes;

  const NotificationEnum(this.code, this.message, this.minutes);

  static NotificationEnum? fromString(String value) {
    try {
      return NotificationEnum.values.firstWhere(
          (e) => e.name == value.toUpperCase() || e.message.toLowerCase() == value.toLowerCase(),
      );
    } catch(e) {
      return null;
    }
  }
}