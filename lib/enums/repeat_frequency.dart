enum RepeatFrequency {
  DOES_NOT_REPEAT(1, 'Não se repete'),
  DAILY(2, 'Todos os dias'),
  WEEKLY(3, 'Semanal'),
  WEEK_DAYS_ONLY(4, 'Segunda a Sexta'),
  MONTHLY(5, 'Mensal');

  final int code;
  final String message;

  const RepeatFrequency(this.code, this.message);

  static RepeatFrequency? fromString(String value) {
    try {
      return RepeatFrequency.values.firstWhere(
          (e) => e.name == value.toUpperCase() || e.message.toLowerCase() == value.toLowerCase(),

      );
    } catch (e) {
      return null;
    }
  }

  String get name => toString().split('.').last;
}