import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jaguar_resty/jaguar_resty.dart' as resty;
import 'package:xml/xml.dart' as xml;
import 'package:yr_no/yr_no.dart';

final client = http.IOClient();

List<xml.XmlElement> _getTimes(String body) {
  xml.XmlDocument doc = xml.parse(body);
  xml.XmlElement product = doc.children.firstWhere((xml.XmlNode node) =>
      node is xml.XmlElement && node.name == xml.XmlName('weatherdata'));
  product = product.children.firstWhere((xml.XmlNode node) =>
      node is xml.XmlElement && node.name == xml.XmlName('product'));
  List<xml.XmlElement> times = product.children
      .where((n) => n is xml.XmlElement)
      .toList()
      .cast<xml.XmlElement>();
  return times;
}

Weather getWeather(List<xml.XmlElement> times) {
  xml.XmlElement cur = times[0];
  xml.XmlElement temperature = cur.findAllElements('temperature').first;
  num temperatureVal = num.tryParse(temperature.getAttribute('value'));
  cur = times[1];
  xml.XmlElement symbol = cur.findAllElements('symbol').first;
  int symbolVal = int.tryParse(symbol.getAttribute('number'));
  return Weather(temperatureVal, symbolVal);
}

Weather getWeatherAt(List<xml.XmlElement> times, DateTime at) {
  xml.XmlElement cur = times.firstWhere((xml.XmlElement el) {
    String from = el.getAttribute('from');
    String to = el.getAttribute('to');
    if (from != to) return false;

    DateTime time = DateTime.tryParse(to);
    if (time.isBefore(at)) return false;
    if (time.difference(at) > Duration(hours: 1)) return false;

    return true;
  });
  xml.XmlElement temperature = cur.findAllElements('temperature').first;
  num temperatureVal = num.tryParse(temperature.getAttribute('value'));
  cur = times.firstWhere((xml.XmlElement el) {
    String to = el.getAttribute('to');
    DateTime time = DateTime.tryParse(to);
    if (time.isBefore(at)) return false;
    if (time.difference(at) > Duration(hours: 1)) return false;
    if (el.findAllElements('symbol').isEmpty) return false;
    return true;
  });
  xml.XmlElement symbol = cur.findAllElements('symbol').first;
  int symbolVal = int.tryParse(symbol.getAttribute('number'));
  return Weather(temperatureVal, symbolVal);
}

DurationWeather getWeatherDay(List<xml.XmlElement> times, DateTime at) {
  num min;
  num max;

  at = DateTime.utc(at.year, at.month, at.day, 12);
  xml.XmlElement cur = times.firstWhere((xml.XmlElement el) {
    String to = el.getAttribute('to');
    DateTime time = DateTime.tryParse(to);
    if (!time.isAtSameMomentAs(at)) return false;
    if (el.findAllElements('minTemperature').isEmpty) return false;
    print(to);
    return true;
  });

  min = num.tryParse(
      cur.findAllElements('minTemperature').first.getAttribute('value'));
  max = num.tryParse(
      cur.findAllElements('maxTemperature').first.getAttribute('value'));

  int icon =
      int.tryParse(cur.findAllElements('symbol').first.getAttribute('number'));

  at = DateTime.utc(at.year, at.month, at.day, 18);
  cur = times.firstWhere((xml.XmlElement el) {
    String to = el.getAttribute('to');
    DateTime time = DateTime.tryParse(to);
    if (!time.isAtSameMomentAs(at)) return false;
    if (el.findAllElements('minTemperature').isEmpty) return false;
    return true;
  });

  {
    num tempMin = num.tryParse(
        cur.findAllElements('minTemperature').first.getAttribute('value'));
    num tempMax = num.tryParse(
        cur.findAllElements('maxTemperature').first.getAttribute('value'));
    if (tempMin < min) min = tempMin;
    if (tempMax > max) max = tempMax;
  }

  return DurationWeather(min, max, icon);
}

DurationWeather getWeatherNight(List<xml.XmlElement> times, DateTime at) {
  num min;
  num max;
  at = at.add(Duration(days: 1));
  at = DateTime.utc(at.year, at.month, at.day, 0);
  xml.XmlElement cur = times.firstWhere((xml.XmlElement el) {
    String to = el.getAttribute('to');
    DateTime time = DateTime.tryParse(to);
    if (!time.isAtSameMomentAs(at)) return false;
    if (el.findAllElements('minTemperature').isEmpty) return false;
    return true;
  });

  min = num.tryParse(
      cur.findAllElements('minTemperature').first.getAttribute('value'));
  max = num.tryParse(
      cur.findAllElements('maxTemperature').first.getAttribute('value'));
  int icon =
      int.tryParse(cur.findAllElements('symbol').first.getAttribute('number'));

  at = DateTime.utc(at.year, at.month, at.day, 6);
  cur = times.firstWhere((xml.XmlElement el) {
    String to = el.getAttribute('to');
    DateTime time = DateTime.tryParse(to);
    if (!time.isAtSameMomentAs(at)) return false;
    if (el.findAllElements('minTemperature').isEmpty) return false;
    return true;
  });

  {
    num tempMin = num.tryParse(
        cur.findAllElements('minTemperature').first.getAttribute('value'));
    num tempMax = num.tryParse(
        cur.findAllElements('maxTemperature').first.getAttribute('value'));
    if (tempMin < min) min = tempMin;
    if (tempMax > max) max = tempMax;
  }

  return DurationWeather(min, max, icon);
}

Future<FullWeather> fetch(num longitude, num latitude) async {
  var now = DateTime.now().toUtc();
  print(now.toIso8601String());
  var threeHours = now.add(Duration(hours: 3));

  resty.StringResponse resp = await resty
      .get('https://api.met.no/weatherapi/locationforecast/1.9/')
      .queries({
    'lat': latitude.toString(),
    'lon': longitude.toString(),
  }).go();
  String body = resp.body;
  // String body = await File('example.xml').readAsString();
  // print(body);

  List<xml.XmlElement> times = _getTimes(body);

  Weather current = getWeather(times);
  print(current);

  Weather in3Hours = getWeatherAt(times, threeHours);
  print(in3Hours);

  final days = <DayWeather>[];

  var dayTime = now.add(Duration(days: 1));
  for (int i = 0; i < 7; i++) {
    dayTime = DateTime.utc(dayTime.year, dayTime.month, dayTime.day);
    DurationWeather dayWeather = getWeatherDay(times, dayTime);
    DurationWeather nightWeather = getWeatherNight(times, dayTime);
    DayWeather day = DayWeather(dayWeather, nightWeather);
    days.add(day);
    dayTime = dayTime.add(Duration(days: 1));

    print(day);
  }
  return FullWeather(current, in3Hours, days);
}

main(List<String> arguments) async {
  resty.globalClient = http.IOClient();
  await fetch(17.53739, 59.42742);
}
