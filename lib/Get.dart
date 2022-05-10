import 'dart:convert';
import 'package:xml/xml.dart';
import 'API_KEYS.dart' as Key;
import 'package:http/http.dart' as http;

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
  cityTest();
}
