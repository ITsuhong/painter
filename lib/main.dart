import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  List<DrawObject> drawObjects = [];
  bool isFirstDraw = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("画板"), backgroundColor: Colors.blue),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            final offset = renderBox.globalToLocal(details.localPosition);

            if (isFirstDraw) {
              print("第一次");
              drawObjects.add(DrawObject([], Colors.blue, 5));
              isFirstDraw = false;
            }
            if (drawObjects.isNotEmpty) {

              drawObjects.last.points.add(offset);
              // print('进来changdu' + drawObjects.last.points.toString());
            }
          });
        },
        onTapUp: (details) {
          // print("抬起");
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            final offset = renderBox.globalToLocal(details.localPosition);
            drawObjects.add(DrawObject([offset], Colors.blue, 5));
            drawObjects.add(DrawObject([], Colors.blue, 5));
            // isFirstDraw = true;
          });
        },
        onPanEnd: (details) {
          setState(() {
            drawObjects.add(DrawObject([], Colors.blue, 5));
            // isFirstDraw = true;
          });
        },
        child: CustomPaint(
          painter: MyPainter(drawObjects: drawObjects),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<DrawObject> drawObjects;

  MyPainter({required this.drawObjects});

  @override
  void paint(Canvas canvas, Size size) {
    for (final drawObject in drawObjects) {
      final paint = Paint()
        ..color = drawObject.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = drawObject.strokeWidth;
      if(drawObject.points.length == 1){
        print("等于1");
        canvas.drawPoints(PointMode.points, [drawObject.points[0]!], paint);
      }
      if (drawObject.points.length > 1) {
        for (int i = 0; i < drawObject.points.length - 1; i++) {
          if (drawObject.points[i] != null &&
              drawObject.points[i + 1] != null) {
            canvas.drawLine(
                drawObject.points[i]!, drawObject.points[i + 1]!, paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// 用户绘制的对象类，包括点和颜色。
class DrawObject {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;

  DrawObject(this.points, this.color, this.strokeWidth);
}
