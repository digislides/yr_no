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
}
