/// Which greeting fits the time of day.
enum GreetingPeriod {
  /// 05:00–11:59.
  morning,

  /// Afternoon, evening and night.
  evening;

  static GreetingPeriod of(DateTime time) =>
      time.hour >= 5 && time.hour < 12 ? morning : evening;
}
