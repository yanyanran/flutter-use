import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Rounded Corners Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // todo 仅Container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              SizedBox(height: 20), // 添加间隔
              // todo 仅ClipRRect
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: MyPainter(),
                  size: Size(100, 100), // 设置画布大小
                ),
              ),
              SizedBox(height: 20), // 添加间隔
              // todo 使用ClipRRect绘制圆角图案，Container填充颜色
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 在这里绘制你的图形，例如一个矩形
    final paint = Paint()..color = Colors.yellow;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}