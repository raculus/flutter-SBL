import 'package:flutter/material.dart';
import 'Get.dart' as Get;

Future<String> fetchData() async{
  var city = Get.City();
  var http = Get.Http();
  var response = await http.body(city.url);
  return response;
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

class ListSearch extends StatefulWidget {
  String title;
  List list;
  ListSearch(this.title, this.list);

  ListSearchState createState() => ListSearchState();
}

class ListSearchState extends State<ListSearch> {
  TextEditingController _textController = TextEditingController();
  String title = "";
  List mainDataList = [];
  List newDataList = [];
  void initState(){
    title = widget.title;
    mainDataList = widget.list;

    // Copy Main List into New List.
    newDataList = List.from(mainDataList);
  }

  onItemChanged(String value) {
    setState(() {
      newDataList = mainDataList
          .where((string) => string.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: title,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  )
              ),
              onChanged: onItemChanged,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(12.0),
              children: newDataList.map((data) {
                return ListTile(
                  title: Text(data),
                  onTap: ()=> print(data),);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}