import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';


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
  String filePath = "";
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
                    onPressed: () {
                      createCanvas();
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

  void createCanvas() async {
    MyPainter _painter = MyPainter(drawObjects: drawObjects);
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    Size boxSize = MediaQuery.of(context).size;
    // 通过 _painter 对象操作 canvas
    _painter.paint(canvas, boxSize);
    ui.Picture picture = recorder.endRecording();
    ui.Image image =
        await picture.toImage(boxSize.width.toInt(), boxSize.height.toInt());
    // 获取字节，存入文件
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    // // 保存图片到相册
    final result = await ImageGallerySaver.saveImage(pngBytes, quality: 100);
    print(result.toString());
    RegExp regExp = RegExp(r'filePath:\s*([^,}]+)');
    Match? match = regExp.firstMatch(result.toString());
    String? value = match?.group(1)!;
    print(value);
    // Map<String, dynamic> map = json.decode(result.toString());
    if (result != null && result != '') {
      // filePath=result.f;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('成功保存至相册'),
          duration: Duration(seconds: 4), // 持续显示时间
          action:SnackBarAction(
            label: '打开',
            onPressed: ()async {

              // 点击关闭按钮时的操作
            },
          ),
        ),
      );
    } else {
      print('保存失败');
    }
    // Fluttertoast.showToast(
    //     msg: "已成功保存至相册",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //     fontSize: 16.0);

  }
}

class MyPainter extends CustomPainter {
  final List<DrawObject> drawObjects;

  MyPainter({required this.drawObjects});

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    var paintBg = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill //填充
      ..color = Colors.white;
    canvas.drawRect(rect, paintBg);
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
