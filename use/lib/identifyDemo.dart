import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '识别功能核心',),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// 定义矩形类
class Rectangle {
  final Offset position;
  final double width;
  final double height;

  Rectangle({required this.position, required this.width, required this.height});
}

// 自定义绘制矩形
class RectanglePainter extends CustomPainter {
  final List<Rectangle> rectangles;
  final Rectangle? selectedRectangle;

  RectanglePainter({required this.rectangles, this.selectedRectangle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    // 绘制所有矩形
    for (final rectangle in rectangles) {
      canvas.drawRect(
        Rect.fromLTWH(
          rectangle.position.dx,
          rectangle.position.dy,
          rectangle.width,
          rectangle.height,
        ),
        paint,
      );
    }

    // 如果有选中的矩形-> 标记为红色
    if (selectedRectangle != null) {
      final selectedPaint = Paint()..color = Colors.red;
      canvas.drawRect(
        Rect.fromLTWH(
          selectedRectangle!.position.dx,
          selectedRectangle!.position.dy,
          selectedRectangle!.width,
          selectedRectangle!.height,
        ),
        selectedPaint,
      );
    }
  }

  // 重绘时返回true来强制重绘
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<Rectangle> rectangles = [
    Rectangle(position: Offset(50, 50), width: 100, height: 50),
    Rectangle(position: Offset(200, 50), width: 100, height: 50),
    Rectangle(position: Offset(250, 20), width: 50, height: 50),
    // 添加更多矩形
  ];

  Rectangle? selectedRectangle;
  String rectangleInfo = '';

  HitTestResult? get hitTestResult => null;

  // 更新坐标信息
  void _onTapDown(TapDownDetails details) {
    final tapPosition = details.localPosition;
    //RendererBinding.instance.hitTestInView(hitTestResult!, tapPosition, );
    Rectangle? smallestRectangle;
    double smallestArea = double.maxFinite;

    // 遍历所有矩形，找到被点击的最小矩形
    for (final rectangle in rectangles) {
      final rect = Rect.fromLTWH(
        rectangle.position.dx,
        rectangle.position.dy,
        rectangle.width,
        rectangle.height,
      );

      if (rect.contains(tapPosition)) {
        final area = rectangle.width * rectangle.height;
        if (area< smallestArea) {
          smallestArea = area;
          smallestRectangle = rectangle;
        }
      }
    }

    // 更新选中的矩形和坐标信息
    setState(() {
      selectedRectangle = smallestRectangle;
      if (selectedRectangle != null) {
        rectangleInfo =
        '长宽信息：宽度=${selectedRectangle!.width}，高度=${selectedRectangle!.height}，边距信息：左边距=${selectedRectangle!.position.dx}，上边距=${selectedRectangle!.position.dy}';
      } else {
        rectangleInfo = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          GestureDetector(  // 检测点击事件
            onTapDown: _onTapDown,
            child: CustomPaint(
              painter: RectanglePainter(
                rectangles: rectangles,
                selectedRectangle: selectedRectangle,
              ),
              size: Size.infinite,
            ),
          ),

          // 底部显示坐标信息
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Text(rectangleInfo),
            ),
          ),
        ],
      ),
    );
  }
}