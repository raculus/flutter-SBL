import 'dart:convert';
import 'package:xml/xml.dart';
import 'API_KEYS.dart' as Key;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

final serviceKey = Key.BUS_KEY;

class Http{
  Future<String> body(String url) async {
    var response = await http.get(Uri.parse(url));
    if(response.statusCode == 200){
      return utf8.decode(response.bodyBytes);
    }
    else{
      print('http response code is not 200');
    }
    return '';
  }
}

class Xml{
  XmlDocument xmlDocument = XmlDocument();
  Xml(){}
  Xml.str(String strXml){
    xmlDocument = XmlDocument.parse(strXml);
  }

  /*
  * xml노드명을 받아 List<dynamic>형태로 반환
  * */
  List elementsToList(String nodeName){
    final elements = xmlDocument.findAllElements(nodeName);
    List list = [];

    for (var elem in elements){
      var text = elem.text;
      var num = int.tryParse(text);
      //int로 형변환 가능한 경우 형 변환
      if(num != null) {
        list.add(num);
      } else{
        list.add(text);
      }
    }
    return list;
  }
}

class Bus{
  String url = '';
  Xml xml = Xml();
  List routeNoList = [];
  List routeIdList = [];

  Bus(int cityCode){
    url = "http://apis.data.go.kr/1613000/BusRouteInfoInqireService/getRouteNoList?serviceKey=$serviceKey&pageNo=1&numOfRows=9999&_type=xml&cityCode=$cityCode";
  }
  Bus.StrXml(String strData){
    xml = Xml.str(strData);

    routeNoList = xml.elementsToList('routeno');
    routeIdList = xml.elementsToList('routeid');
  }
  // routeNo는 버스번호 (ex: 212)
  routeNo2Id(int routeNo){
    int index = routeNoList.indexOf(routeNo);
    if(index != -1){
      //
      return routeIdList[index];
    }
    return -1;
  }
}

class City{
  String url = '';
  String strXml = '';
  Xml xml = Xml();
  List cityCodeList = [];
  List cityNameList = [];

  City(){
    url = 'http://apis.data.go.kr/1613000/BusRouteInfoInqireService/getCtyCodeList?serviceKey=$serviceKey&_type=xml';
  }
  City.StrXml(String strData){
    this.strXml = strData;
    xml = Xml.str(strData);
    cityCodeList = xml.elementsToList('citycode');
    cityNameList = xml.elementsToList('cityname');
  }
  /*
  * 도시명 (예시: 창원, 창원시)을 받아
  * 지역명에 맞는 도시코드 반환
  * */
  int name2code(String cityName){
    var fullNames = cityNameList.where((name) => name.contains(cityName));
    for(var name in fullNames){
      int index = cityNameList.indexOf(name);
      return cityCodeList[index];
    }
    return -1;
  }
}
class Station{
  Future<List> getNearby(double lati, double long) async {
    final url = 'http://apis.data.go.kr/1613000/BusSttnInfoInqireService/getCrdntPrxmtSttnList?serviceKey=$serviceKey&pageNo=1&numOfRows=9999&_type=xml&gpsLati=$lati&gpsLong=$long';
    Http http = Http();
    var body = await http.body(url);
    Xml xml = Xml.str(body);

    List nameList = xml.elementsToList('nodenm'); //정류장 이름 ex:시티세븐
    List numList = xml.elementsToList('nodeno'); //정류장 번호 ex:35132
    List idList = xml.elementsToList('nodeid'); //정류장 id ex:CWB45625
    List stationList = [];
    int i = 0;
    for(var id in idList){
      var value = {'Name':nameList[i], 'Num':numList[i], 'Id':id};
      stationList.add(value);
      i++;
    }
    return stationList;
  }
}

/*
* 테스트 코드
* */
void cityTest(){
  City city = City();

  var strFuture = Http().body(city.url);
  strFuture.then((String result){
    var strXml = result;
    City city = City.StrXml(strXml);
    print(city.cityNameList);
  });
}

void busTest(){
  cityTest();
  //38010 -> 창원시코드
  Bus bus = Bus(38010);
  bus = Bus.StrXml("");
  //212 -> 버스번호
  print(bus.routeNo2Id(212));
}
void main(){
  Station station = Station();
  var nearby = station.getNearby(35.2552783,128.6427089);
  nearby.then((value){
    for(Map item in value){
      var name = item['Name'];
      var num = item['Num'];
      var id = item['Id'];
      print('정류장: $name, 번호: $num, ID: $id');
    }
  });
}
