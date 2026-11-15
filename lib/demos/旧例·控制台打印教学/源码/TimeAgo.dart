class TimeAgo {
  int totalSeconds;

  int yearsAgo = 0;
  int monthsAgo = 0;
  int daysAgo = 0;
  int hoursAgo = 0;
  int minutesAgo = 0;
  int secondsAgo = 0;

  TimeAgo(this.totalSeconds) {
    _calculate();
  }

  void _calculate() {
    int remainingSeconds = totalSeconds;

    yearsAgo = remainingSeconds ~/ (365 * 24 * 60 * 60);
    remainingSeconds %= (365 * 24 * 60 * 60);

    monthsAgo = remainingSeconds ~/ (30 * 24 * 60 * 60);
    remainingSeconds %= (30 * 24 * 60 * 60);

    daysAgo = remainingSeconds ~/ (24 * 60 * 60);
    remainingSeconds %= (24 * 60 * 60);

    hoursAgo = remainingSeconds ~/ (60 * 60);
    remainingSeconds %= (60 * 60);

    minutesAgo = remainingSeconds ~/ 60;
    secondsAgo = remainingSeconds % 60;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSeconds': totalSeconds,
      'yearsAgo': yearsAgo,
      'monthsAgo': monthsAgo,
      'daysAgo': daysAgo,
      'hoursAgo': hoursAgo,
      'minutesAgo': minutesAgo,
      'secondsAgo': secondsAgo,
    };
  }
}
