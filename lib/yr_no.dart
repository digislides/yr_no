class Weather {
  num temperature;
  int icon;
  Weather(this.temperature, this.icon);

  String toString() => 'Weather(temperature: $temperature, icon: $icon)';
}

class DurationWeather {
  num min;
  num max;
  int icon;
  DurationWeather(this.min, this.max, this.icon);

  String toString() => 'DurationWeather(min: $min, max: $max, icon: $icon)';
}

class DayWeather {
  DurationWeather day;
  DurationWeather night;
  DayWeather(this.day, this.night);

  String toString() => 'DurationWeather(day: $day, night: $night)';
}

class FullWeather {
  Weather current;

  Weather in3Hours;

  List<DayWeather> days;

  FullWeather(this.current, this.in3Hours, this.days);

  String toString() {
    var sb = StringBuffer();

    sb.writeln('Current: $current');
    sb.writeln('In 3 hours: $in3Hours');
    sb.writeln('Days:');
    days.forEach((w) => sb.writeln(w));

    return sb.toString();
  }
}
