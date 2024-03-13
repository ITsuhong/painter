import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
  Color pickerColor = Color(0xff443a49);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     title: Text("画板", style: TextStyle(color: Colors.white)),
      //     backgroundColor: Colors.blue),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            final offset = renderBox.globalToLocal(details.localPosition);
            if (isFirstDraw) {
              drawObjects.add(DrawObject([], pickerColor, 5));
              isFirstDraw = false;
            }
            if (drawObjects.isNotEmpty) {
              drawObjects.last.points.add(offset);
              // drawObjects.last.changeColor(pickerColor);
              // print('进来changdu' + drawObjects.last.points.toString());
            }
          });
        },
        onTapUp: (details) {
          // print("抬起");
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            final offset = renderBox.globalToLocal(details.localPosition);

            drawObjects.add(DrawObject([offset], pickerColor, 5));
            drawObjects.add(DrawObject([], pickerColor, 5));
            // isFirstDraw = true;
          });
        },
        onPanEnd: (details) {
          setState(() {
            drawObjects.add(DrawObject([], pickerColor, 5));
            isFirstDraw = true;
          });
        },
        child: Stack(
          children: [
            CustomPaint(
              painter: MyPainter(drawObjects: drawObjects),
              size: Size.infinite,
            ),
            Positioned(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.av_timer),
                    color: Colors.white,
                    iconSize: 25.0,
                    onPressed: () {
                      selectColor();
                    },
                  ),
                ),
                left: 20,
                bottom: 180),
            Positioned(
                left: 20,
                bottom: 120,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.reply_all),
                    color: Colors.white,
                    iconSize: 25.0,
                    onPressed: () {
                      // selectColor();
                      setState(() {
                        if (drawObjects.isNotEmpty) {
                          drawObjects.removeAt(drawObjects.length - 1);
                          drawObjects.removeAt(drawObjects.length - 1);
                        }
                      });
                    },
                  ),
                )),
            Positioned(
                left: 20,
                bottom: 60,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.download),
                    color: Colors.white,
                    iconSize: 25.0,
                    onPressed: () async {
                      getImageFromCanvas(Size(100.0, 100.0)).then((image) {
                        print('image' + image.toString());
                        // Image.memory(image.toByteData());
                      });
                    },
                  ),
                ))
          ],
        ),
      ),
    );
  }

  void selectColor() {
    showDialog(
      context: context,
      builder: (context) {
        Color newColor = pickerColor;
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                newColor = color;
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('确定'),
              onPressed: () {
                setState(() => pickerColor = newColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

   getImageFromCanvas(Size size) async {
   ui.PictureRecorder recorder = ui.PictureRecorder();
    final picture = recorder.endRecording();
    ui.Image img = await picture.toImage(
        size.width.toInt() + 40, size.height.toInt() + 40);
    // 转换为png格式的图片数据
    var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
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
        ..strokeWidth = drawObject.strokeWidth
        ..isAntiAlias = true; //抗锯齿
      ;
      if (drawObject.points.length == 1) {
        canvas.drawPoints(ui.PointMode.points, [drawObject.points[0]!], paint);
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
  late final Color color;
  final double strokeWidth;

  DrawObject(this.points, this.color, this.strokeWidth);
}
