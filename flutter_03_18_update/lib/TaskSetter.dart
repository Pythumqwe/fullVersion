import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_03_18_update/globalVariable.dart';


class TaskSetter extends StatefulWidget {
  const TaskSetter({super.key});

  @override
  State<TaskSetter> createState() => _TaskSetterState();
}

class _TaskSetterState extends State<TaskSetter> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: ListView.builder(
          itemCount: scheduleData.length,
          itemBuilder: (context,index){
            final temp = scheduleData[index];
            return TaskItem(schedule: temp);
          },
        ),
      ),
    );
  }
}



class TaskItem extends StatefulWidget {
  final Map<String,dynamic> schedule;
  const TaskItem({super.key,required this.schedule});

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.schedule["date"],
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        Row(
          children: widget.schedule["blocks"].map<Widget>((element){
            if (element["type"] == "empty"){
              return Expanded(
                flex: element["duration"],
                child: DragTarget<Map<String,dynamic>>(
                  onAcceptWithDetails: (detail){
                    setState(() {
                      int draggedDuration = detail.data["duration"];
                      if(element["duration"] > draggedDuration){
                        int currentIndex = widget.schedule["blocks"].indexOf(element);
                        int remainingDuration = element["duration"] - draggedDuration;
                        setState(() {
                          element["type"] = detail.data["type"];
                          element["duration"] = draggedDuration;
                          element["opacity"] = 0.0;
                        });

                        widget.schedule["blocks"].insert(currentIndex + 1, {"type" : "empty","duration" : remainingDuration,"opacity" : 1.0});

                        Future.delayed(Duration(milliseconds: 300),(){
                          setState(() {
                            element["opacity"] = 1.0;
                          });
                        });

                      }else{
                        element["type"] = detail.data["type"];
                        element["opacity"] = 0.0;

                        Future.delayed(Duration(milliseconds: 300),(){
                          setState(() {
                            element["opacity"] = 1.0;
                          });
                        });
                      }
                    });
                  },
                  builder: (p0,y,p1){
                    return AnimatedOpacity(
                      opacity: element["opacity"],
                      duration: Duration(milliseconds: 300),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: y.isEmpty ? Colors.grey : Colors.yellow,
                        ),
                        child: Center(
                          child: Text(
                            "Empty",
                            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }else{
              return Expanded(
                flex: element["duration"],
                child: GestureDetector(
                  onDoubleTap: (){
                      if(element["type"] == "empty") return;

                      setState(() {
                        element["opacity"] = 0.0;
                      });

                      int currentIndex = widget.schedule["blocks"].indexOf(element);
                      int duration = element["duration"];
                      Future.delayed(Duration(milliseconds: 300),(){
                        widget.schedule["blocks"].removeAt(currentIndex);

                        if(currentIndex > 0 && widget.schedule["blocks"][currentIndex - 1]["type"] == "empty"){
                          widget.schedule["blocks"][currentIndex - 1]["duration"] += duration;
                        }else if(currentIndex < widget.schedule["blocks"].length && widget.schedule["blocks"][currentIndex]["type"] == "empty" ){
                          widget.schedule["blocks"][currentIndex]["duration"] += duration;
                        }else if(currentIndex != 0 && widget.schedule["blocks"][currentIndex - 1]["type"] == "empty" && widget.schedule["blocks"][currentIndex]["type"] == "empty" ){
                          widget.schedule["blocks"][currentIndex - 1] += (duration + widget.schedule["blocks"][currentIndex]["duration"]);
                        }else{
                          widget.schedule["blocks"].insert(currentIndex , {"type" : "empty","duration" : duration,"opacity" : 1.0});
                        }

                        setState(() {});
                      });
                  },
                  onHorizontalDragUpdate: (detail){
                    setState(() {
                      int change = (detail.primaryDelta! ~/ 1).toInt();
                      if (change == 0) return;
                      if(change > 1) return;
                      int emptyBlockIndex = widget.schedule["blocks"].indexWhere((target)=> target["type"] == "empty");
                      if (change > 0){
                        if(emptyBlockIndex != -1){
                          int actualChange = min(element["duration"], change);
                          element["duration"] += actualChange;
                          widget.schedule["blocks"][emptyBlockIndex]["duration"] -= actualChange;

                          if(widget.schedule["blocks"][emptyBlockIndex]["duration"] == 0){
                            widget.schedule["blocks"].removeAt(emptyBlockIndex);
                          }
                        }
                      }else{
                        int currentIndex = widget.schedule["blocks"].indexOf(element);
                        if(element["duration"] + change > 0){
                          element["duration"] += change;
                          if(emptyBlockIndex != -1){
                            var emptyBlock = widget.schedule["blocks"][emptyBlockIndex];
                            emptyBlock["duration"] -= change;
                          }else{
                            widget.schedule["blocks"].insert(currentIndex + 1, {"type" : "empty","duration": -change,"opacity" : 1.0});
                          }
                        }
                      }
                    });
                  },
                  child: AnimatedOpacity(
                    opacity: element["opacity"],
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      height: 40,
                      decoration: BoxDecoration(
                        color: element["type"] == "work" ? Colors.black : Colors.green,
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Center(
                        child: Text(
                          element["type"],
                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }).toList(),
        )
      ],
    );
  }
}
























