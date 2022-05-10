import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


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