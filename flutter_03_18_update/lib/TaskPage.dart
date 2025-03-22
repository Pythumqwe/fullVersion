import 'package:flutter/material.dart';
import 'package:flutter_03_18_update/ChartPainter.dart';
import 'package:flutter_03_18_update/TaskSetter.dart';
import 'package:flutter_03_18_update/ToolBox.dart';
import 'package:flutter_03_18_update/globalVariable.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with TickerProviderStateMixin {
  late AnimationController chartAnimationController;
  late Animation chartAnimation;

  @override
  void initState() {
    super.initState();
    chartAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    chartAnimationController.addListener(() => setState(() {}));

    chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
        CurvedAnimation(
            parent: chartAnimationController,
            curve: Curves.linear,
        ),
    );
    startAnimation();
  }

  void startAnimation() {
    chartAnimationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: AnimatedBuilder(
              key:  ValueKey(chartAnimation.value),
              animation: chartAnimation,
              builder: (context,child){
                return CustomPaint(
                  size: Size(300, 300),
                  painter: ChartPainter(
                      data: scheduleData,
                      animationValue: chartAnimationController.value
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableContainer(
              callToAnimation: startAnimation,
            ),
          )
        ],
      ),
    );
  }
}

class DraggableContainer extends StatefulWidget {
  final VoidCallback callToAnimation;
  const DraggableContainer({super.key, required this.callToAnimation});

  @override
  State<DraggableContainer> createState() => _DraggableContainerState();
}

class _DraggableContainerState extends State<DraggableContainer> {
  double currentHeight = 50;
  static const double MIN_HEIGHT = 50;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: currentHeight,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          controller(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: currentHeight >= 150,
                child: Toolbox(),
              ),
              SizedBox(
                width: 5,
              ),
              Visibility(
                visible:
                    currentHeight > MediaQuery.sizeOf(context).height * 0.75,
                child: TaskSetter(),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget controller() {
    return GestureDetector(
      onVerticalDragUpdate: (detail) {
        setState(() {
          currentHeight -= detail.primaryDelta!;
          currentHeight = currentHeight.clamp(MIN_HEIGHT, MediaQuery.sizeOf(context).height);
          if(currentHeight == 50){
            widget.callToAnimation();
          }
        });
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.6,
        height: 10,
        margin: EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
