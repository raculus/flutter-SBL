import 'package:flutter/material.dart';
import 'listViewTest.dart';
import 'Get.dart' as Get;
import 'HttpReq.dart' as http_req;

void main() {
  runApp(const MyApp());
}

Future<String> fetchData() async{
  var city = Get.City();
  var response = await http_req.body(city.url);
  return response;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyPage(),);
  }
}

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SBL'),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GetCity(),
    );
  }
}

class GetCity extends StatefulWidget {
  const GetCity({Key? key}) : super(key: key);

  @override
  State<GetCity> createState() => _GetCityState();
}

class _GetCityState extends State<GetCity> {
  late Future<String> futureData;

  @override
  void initState(){
    super.initState();
    futureData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
      return FutureBuilder<String>(
        future: futureData,
        builder: (context, snapshot){
          if(snapshot.hasData){
            String? str = snapshot.data;
            Get.City city = Get.City.StrXml(str.toString());
            return ListSearch("도시명", city.cityNameList);
          }
          else if(snapshot.hasError){
            return Text('${snapshot.error}');
          }
          return const Center(child: CircularProgressIndicator(),);
        }
      );
  }
}