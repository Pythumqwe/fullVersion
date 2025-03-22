import 'dart:math';

import 'package:flutter/material.dart';
import 'globalVariable.dart';


class ClockPainter extends CustomPainter{
  final Duration leftTime;
  ClockPainter({required this.leftTime});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = center.dx;

    final hourDegree = (leftTime.inHours % 24) * 15 + (leftTime.inMinutes % 60) * 0.25;
    final minuteDegree = ((leftTime.inMinutes % 60) * 6 + (leftTime.inSeconds % 60) * 0.1).toDouble();
    final secondDegree = ((leftTime.inSeconds % 60) * 6).toDouble();

    drawCircle(canvas, center, radius);
    drawCircle(canvas, center, radius * 1.4);
    drawTick(canvas, center, radius, 60);
    drawTick(canvas, center, radius * 1.4, 24);
    drawNumber(canvas, center, radius, 12);
    drawNumber(canvas, center, radius * 1.4, 24);
    drawPointer(canvas, center, radius * 0.7, secondDegree, 1.0, Colors.blue);
    drawPointer(canvas, center, radius * 0.6, minuteDegree, 2.0, Colors.grey);
    drawPointer(canvas, center, radius * 0.45, hourDegree, 3.0, Colors.black);
  }

  void drawCircle(Canvas canvas,Offset c,double r){
    Paint paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

    canvas.drawCircle(c, r, paint);
  }

  void drawTick(Canvas canvas,Offset center,double radius,int value){
    Paint paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1.0;
    for(int i = 0; i < value; i++){
      final radian = toRadian(i * (360 / value));
      Offset endPos;

      Offset startPos = Offset(
          center.dx + radius * cos(radian),
          center.dy + radius * sin(radian)
      );

      if(value == 60){
        if(i % 5 == 0){
          endPos = Offset(
              center.dx + (radius * 0.85) * cos(radian),
              center.dy + (radius * 0.85) * sin(radian)
          );
        }else{
          endPos = Offset(
              center.dx + (radius * 0.9) * cos(radian),
              center.dy + (radius * 0.9) * sin(radian)
          );
        }
      }else{
        endPos = Offset(
            center.dx + (radius * 0.9) * cos(radian),
            center.dy + (radius * 0.9) * sin(radian)
        );
      }
      canvas.drawLine(startPos, endPos, paint);
    }
  }

  void drawNumber(Canvas canvas,Offset center,double radius,int value){
    for(int i = 0; i < value; i++){
      final radian = toRadian(i * (360 / value) - 90);
      TextSpan textSpan;

      if(value == 12){
        textSpan = TextSpan(
          text: (i * 5).toString(),
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 10)
        );
      }else{
        textSpan = TextSpan(
          text: i.toString(),
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 12),
        );
      }

      TextPainter textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr
      );
      textPainter.layout();

      Offset textCenter = Offset(
        center.dx + radius * 0.8 * cos(radian),
        center.dy + radius * 0.8 * sin(radian)
      );

      Offset textPos = Offset(
        textCenter.dx - textPainter.width / 2,
        textCenter.dy - textPainter.height / 2
      );

      textPainter.paint(canvas, textPos);
    }
  }

  void drawPointer(Canvas canvas,Offset center,double radius,double degree,double width,Color color){
    Paint paint = Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;

    Offset endPos = Offset(
      center.dx + radius * cos(toRadian(degree - 90)),
      center.dy + radius * sin(toRadian(degree - 90))
    );

    canvas.drawLine(center, endPos, paint);
  }

  double toRadian(double degree){
    return degree * (pi / 180);
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.leftTime != g_leftTime;
  }

}