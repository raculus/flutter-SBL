import 'dart:convert';
import 'API_KEYS.dart' as Key;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';



String pos = '127.898283,34.8373363';
String pos2 = '128.6427089,35.2552783';

void getPlaceAddress(double lat, double lng) async{
  final pos = '$lat,$lng';
  final url = 'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=$pos&output=xml';
  final response = await fetchPost(url);
  
  XmlDocument xmlDocument = XmlDocument();
  xmlDocument = XmlDocument.parse(response);
  
  var area2 = xmlDocument.findAllElements('area2').first;
  var name = area2.firstChild;
  print(pos+' is ');
  print(name?.text.toString());
}

Future<String> fetchPost(String url) async {
  Map<String, String> headers = {
    "X-NCP-APIGW-API-KEY-ID" : Key.NAVER_CLIENT_ID,
    "X-NCP-APIGW-API-KEY" : Key.NAVER_CLIENT_SECRET
  };

  final response = await http.get(Uri.parse(url),headers: headers);
  return utf8.decode(response.bodyBytes);
}

Future<Position> getCurrentLocation() async{
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high
  );
  return position;
}

void testGps(){
  var pos = getCurrentLocation();
  pos.then((value){
    print('위도: ${value.latitude}');
    print('경도: ${value.longitude}');
    getPlaceAddress(value.latitude, value.longitude);
  });
}

void main(){
  getPlaceAddress(128.6427089,35.2552783);
}