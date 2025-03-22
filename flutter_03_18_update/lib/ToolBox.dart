import 'package:flutter/material.dart';



class Toolbox extends StatefulWidget {
  const Toolbox({super.key});

  @override
  State<Toolbox> createState() => _ToolboxState();
}

class _ToolboxState extends State<Toolbox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.2,
      height: 120,
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(width: 1)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Tool(type: "work"),
          Tool(type: "rest")
        ],
      ),
    );
  }
}


class Tool extends StatelessWidget {
  final String type;
  const Tool({super.key,required this.type});

  @override
  Widget build(BuildContext context) {
    return Draggable<Map<String,dynamic>>(
      data: {"type" : type,"duration" : 2,"opacity" : 1.0},
      feedback: this,
      child: Container(
        width: 100,
        height: 40,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: type == "work" ? Colors.black : Colors.green,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Center(
          child: Text(
            type,
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12),
          ),
        ),
      ),
    );
  }
}
