import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jaguar_resty/jaguar_resty.dart' as resty;
import 'package:xml/xml.dart' as xml;

final client = http.IOClient();

Iterable<xml.XmlElement> filterUneccesary(xml.XmlElement input) {
  // xml.XmlElement location = input.findElements('location');
}

Future<dynamic> fetch(num longitude, num latitude) async {
  /*
  resty.StringResponse resp = await resty
      .get('https://api.met.no/weatherapi/locationforecast/1.9/')
      .queries({
    'lat': latitude.toString(),
    'lon': longitude.toString(),
  }).go();
  String body = resp.body;
  */
  String body = await File('example.xml').readAsString();
  print(body);
  
  xml.XmlDocument doc = xml.parse(body);
  Iterable items = doc.findAllElements('time');
  print(items.length);
}

main(List<String> arguments) async {
  resty.globalClient = http.IOClient();

  await fetch(17.53739, 59.42742);
}
