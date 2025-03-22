import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_03_18_update/ClockPainter.dart';
import 'package:flutter_03_18_update/TaskPage.dart';
import 'package:flutter_03_18_update/globalVariable.dart';

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
  Timer? timer;
  final TextEditingController cHour = TextEditingController();
  final TextEditingController cMinute = TextEditingController();
  final TextEditingController cSecond = TextEditingController();

  bool isCounting = false;
  bool isSet = false;

  void startClock(){
    timer = Timer.periodic(Duration(seconds: 1), (timer){
      if(g_leftTime >= Duration(seconds: 1)){
        setState(() {
          g_leftTime -= Duration(seconds: 1);
        });
      }else{
        timer.cancel();
        setState(() {
          isCounting = false;
        });
      }
    });
  }


  static const platform = MethodChannel("shake_channel");
  
  
  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(onFlutterEvent);
  }

  Future<void> onFlutterEvent(MethodCall call) async{
    if(call.method == "onShake"){
      setState(() {
        print("Fired");
        timer?.cancel();
        isCounting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: myAppBar(),
        body: TabBarView(
          children: [
            clockPage(g_leftTime),
            TaskPage()
          ],
        ),
      ),
    );
  }
  AppBar myAppBar(){
    return AppBar(
      title: Text("Tomato Bo"),
      bottom: TabBar(
        tabs: [
          Tab(text: "Clock"),
          Tab(text: "Task")
        ],
      ),
    );
  }
  Widget clockPage(Duration leftTime){
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            spacing: 5,
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: cHour,
                  decoration: InputDecoration(
                      hintText: "Hour",
                      border: OutlineInputBorder(borderSide: BorderSide(width: 1))
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: cMinute,
                  decoration: InputDecoration(
                    hintText: "Minute",
                    border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: cSecond,
                  decoration: InputDecoration(
                    hintText: "Second",
                    border: OutlineInputBorder(borderSide: BorderSide(width: 1)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
          CustomPaint(
            size: Size(200, 200),
            painter: ClockPainter(leftTime: leftTime),
          ),
          SizedBox(height: 50),
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (){
                  if(!isSet) return;
                  if(isCounting){
                    timer?.cancel();
                    isCounting = false;
                  }else{
                    startClock();
                    isCounting = true;
                  }
                  setState(() {});
                },
                child: Text(isCounting ? "pause" : "start"),
              ),
              ElevatedButton(
                onPressed: (){
                  if(isSet){
                    isSet = false;
                    isCounting = false;
                    g_leftTime = Duration.zero;
                    setState(() {});
                    return;
                  }
                  if(cHour.text.isEmpty || cMinute.text.isEmpty || cSecond.text.isEmpty) return;

                  setState(() {
                    g_leftTime = Duration(
                        hours: int.parse(cHour.text),
                        minutes: int.parse(cMinute.text),
                        seconds: int.parse(cSecond.text)
                    );
                    isSet = true;
                  });
                  },
                child: Text(isSet ? "reset" : "setUp"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
