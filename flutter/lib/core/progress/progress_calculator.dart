class YearMonth implements Comparable<YearMonth> {
  final int year;
  final int month;

  YearMonth(this.year, this.month);

  factory YearMonth.fromDateTime(DateTime dt) => YearMonth(dt.year, dt.month);

  factory YearMonth.fromEpochDay(int epochDay) {
    final dt = DateTime.fromMillisecondsSinceEpoch(
      epochDay * 24 * 60 * 60 * 1000,
      isUtc: true,
    );
    return YearMonth(dt.year, dt.month);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearMonth &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month;

  @override
  int get hashCode => year.hashCode ^ month.hashCode;

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}';

  @override
  int compareTo(YearMonth other) {
    if (year != other.year) return year.compareTo(other.year);
    return month.compareTo(other.month);
  }

  YearMonth plusMonths(int months) {
    var newMonth = month + months;
    var newYear = year;
    while (newMonth > 12) {
      newMonth -= 12;
      newYear += 1;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear -= 1;
    }
    return YearMonth(newYear, newMonth);
  }
}

class ProgressCalculator {
  static int percentage(int completed, int total) {
    if (total <= 0) return 0;
    return ((completed * 100) ~/ total).clamp(0, 100);
  }

  static Map<YearMonth, int> completedSessionsByMonth(
    List<int> completedEpochDays,
  ) {
    final result = <YearMonth, int>{};
    for (var day in completedEpochDays) {
      final ym = YearMonth.fromEpochDay(day);
      result[ym] = (result[ym] ?? 0) + 1;
    }
    return result;
  }

  static int weeklyStreak({
    required List<int> completedEpochDays,
    required int targetPerWeek,
    required int currentEpochDay,
  }) {
    if (targetPerWeek <= 0) return 0;

    final completionsByWeek = <int, int>{};
    for (var day in completedEpochDays) {
      final mon = _mondayOfWeek(day);
      completionsByWeek[mon] = (completionsByWeek[mon] ?? 0) + 1;
    }

    final currentWeek = _mondayOfWeek(currentEpochDay);
    var week = (completionsByWeek[currentWeek] ?? 0) >= targetPerWeek
        ? currentWeek
        : currentWeek - 7;

    var streak = 0;
    while ((completionsByWeek[week] ?? 0) >= targetPerWeek) {
      streak++;
      week -= 7;
    }
    return streak;
  }

  static int _mondayOfWeek(int epochDay) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      epochDay * 24 * 60 * 60 * 1000,
      isUtc: true,
    );
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return monday.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
  }
}
