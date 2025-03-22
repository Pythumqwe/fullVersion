import 'package:flutter/material.dart';
import 'package:flutter_03_18_update/globalVariable.dart';

class ChartPainter extends CustomPainter{
  final double animationValue;
  final List<Map<String,dynamic>> data;
  ChartPainter({required this.data,required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(0, size.height);

    drawAxis(canvas, origin, size);
    drawTick(canvas, origin, size);
    drawNumber(canvas, origin, size);
    drawData(canvas, origin, size);
  }

  void drawAxis(Canvas canvas,Offset o,Size size){
    Paint paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round;

    Offset xAxisEnd = Offset(
      size.width,
      o.dy,
    );
    Offset yAxisEnd = Offset(
      0,
      0,
    );

    canvas.drawLine(o, xAxisEnd, paint);
    canvas.drawLine(o, yAxisEnd, paint);
  }

  void drawTick(Canvas canvas,Offset o,Size size){
    Paint paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 3.0;

    for(int i = 1; i <= 7; i++){
      double distance = i * ((size.width - 20) / 7);

      Offset startPos = Offset(
        o.dx + distance,
        o.dy
      );

      Offset endPos = Offset(
        o.dx + distance,
        o.dy - 10
      );

      canvas.drawLine(startPos, endPos, paint);
    }

    for(int i = 1; i <= 12; i++){
      double distance = i * ((size.width - 20) / 12);

      Offset startPos = Offset(
          o.dx,
          o.dy - distance
      );

      Offset endPos = Offset(
          o.dx + 10,
          o.dy - distance
      );

      canvas.drawLine(startPos, endPos, paint);
    }
  }

  void drawNumber(Canvas canvas,Offset o,Size size){
    for(int i = 1; i <= 7; i++){
      final distance = i * ((size.width - 20) / 7);

      TextSpan textSpan = TextSpan(
        text: scheduleData[i - 1]["date"],
        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 10),
      );

      TextPainter textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr
      );
      textPainter.layout();

      Offset textCenter = Offset(
        o.dx + distance,
        o.dy + 10
      );

      Offset textPos = Offset(
        textCenter.dx - textPainter.width  / 2,
        textCenter.dy - textPainter.height / 2
      );

      textPainter.paint(canvas, textPos);
    }
    for(int i = 1; i <= 12; i++){
      final distance = i * ((size.height - 20) / 12);

      TextSpan textSpan = TextSpan(
        text: i.toString(),
        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 12),
      );

      TextPainter textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr
      );
      textPainter.layout();

      Offset textCenter = Offset(
          o.dx - 15,
          o.dy - distance
      );

      Offset textPos = Offset(
          textCenter.dx - textPainter.width  / 2,
          textCenter.dy - textPainter.height / 2
      );

      textPainter.paint(canvas, textPos);
    }
  }

  void drawData(Canvas canvas,Offset o,Size size){
    Paint paint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 3.0
    ..strokeCap = StrokeCap.round;
    for(int i = 1; i <= 7; i++){
      final xDistance = i * ((size.width - 20) / 7);
      int workTime = 0;
      scheduleData[i - 1]["blocks"].forEach((block){
        if(block["type"] == "work") workTime += block["duration"] as int;
      });

      Offset startPos = Offset(
        o.dx + xDistance,
        o.dy
      );

      Offset endPos = Offset(
        o.dx + xDistance,
        o.dy - workTime * ((size.height - 20) / 12) * animationValue
      );

      canvas.drawLine(startPos, endPos, paint);
    }
  }





  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.data != scheduleData;
  }
}