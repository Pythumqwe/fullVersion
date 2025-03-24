import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Map<String,dynamic>> fetchData() async{
    const url = "https://randomuser.me/api/";
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    
    if(response.statusCode == 200){
      final jsonString = await response.transform(utf8.decoder).join();
      final Map<String,dynamic> temp = await jsonDecode(jsonString);
      return temp;
    }else if(response.statusCode == 401){
      print("please get Key");
    }else{
      print("Get data error");
    }

    return {};
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: fetchData(), 
        builder: (context,s){
          if(s.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }else if(s.hasError){
            return Center(child: Text("load error"));
          }else if(s.data!.isEmpty){
            return Center(child: Text("no data found"));
          }else{
            final data = s.data!;
            return Column(
              children: [
                ListTile(
                  title: Text("name: ${data["results"][0]["name"]["title"]} ${data["results"][0]["name"]["first"]}"),
                  subtitle: Text("gender: ${data["results"][0]["gender"]}"),
                )
              ],
            );
          }
        },
      ),
    );
  }
}
