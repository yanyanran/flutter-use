import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../tools/hitTestTools.dart' as tools;

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
      home: ScaffoldRoute(),
    );
  }
}

final GlobalKey<_DragState> key = GlobalKey<_DragState>();

// 大页面骨架
class ScaffoldRoute extends StatefulWidget {
  @override
  _ScaffoldRouteState createState() => _ScaffoldRouteState();
}

class _ScaffoldRouteState extends State<ScaffoldRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar( //导航栏
        title: Text("Demo"),
      ),
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
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // 添加间隔
            // todo 仅ClipRRect
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: MyPainter(),
                size: Size(100, 100), // 设置画布大小
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomPaint(
                      painter: MyPainterTest(),
                      size: Size(60, 60), // 设置画布大小
                    ),
                  ),
                ),
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
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ), // globalKey传给列表
      floatingActionButton: Drag(key),  // 可拖拉悬浮按钮  globalKey传给按钮
    );
  }
}

// 可拖拉按钮
class Drag extends StatefulWidget {
  const Drag(GlobalKey<_DragState> key);

  @override
  _DragState createState() => _DragState();
}

typedef InspectorSelectButtonBuilder = Widget Function(BuildContext context, VoidCallback onPressed);
late final InspectorSelectButtonBuilder? inspectorSelectButtonBuilder;

class _DragState extends State<Drag> with SingleTickerProviderStateMixin {
  double _top = 700.0; //距顶部的偏移
  double _left = 320.0;//距左边的偏移
  late OverlayEntry _overlayEntry;

  // 确定用户点击的位置是否在列表范围内【重写hitTest】
  void _inspector(TapDownDetails details) {
    final tapPosition = details.globalPosition;
    final renderObj = key.currentContext?.findRenderObject();
    tools.WidgetInspectorState inn = tools.WidgetInspectorState();
    final resList = inn.hitTest(tapPosition, renderObj!);

    // todo 遍历识别是否存在RenderDecoratedBox或RenderClipRRect
    for (final render in resList) {
      if(render is RenderDecoratedBox) {
        var dec = render.decoration as BoxDecoration;
        print("---------识别到RenderDecoratedBox: radius为${dec}---------");
        break;
      } else if (render is RenderClipRRect) {
        print("--------识别到RenderClipRRec: radius为${render.borderRadius}---------");
        break;
      } else {
        print("--------【不存在圆角！】---------");
      }
    }

    final RenderBox render = resList[0] as RenderBox;
    // print("【！log！】${resList[0]}");  // 获取最上层的组件
    final Rect bounds = render.paintBounds;  // 边界
    final Size size = render.size;  // 大小
    final Offset position = render.localToGlobal(Offset.zero);  // 位置
    print("【widget】大小：${size}, 边界：${bounds}, 位置：${position}");
  }

  // 全屏遮罩
  void _showOverlay(GlobalKey<_DragState> key) {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(  // 手势识别
            behavior: HitTestBehavior.translucent,
            onTap: () {  // 点击事件
              print("识别到遮罩层onTap");
            },
            onTapDown: (TapDownDetails details) {
              _inspector(details);
            },
            onLongPress: () { // 长按遮罩消失
              _overlayEntry.remove();
            },
            child: Container(  // 全屏遮罩
              color: Colors.blueGrey.withOpacity(0.2),
              child: const Center(
                child: Text('inspector模式', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: _top,
          left: _left,
          child: GestureDetector(
            child: CircleAvatar(child: Text("+")),
            //手指按下时会触发此回调
            onPanDown: (DragDownDetails e) {
              //打印手指按下的位置(相对于屏幕)
              print("用户手指按下：${e.globalPosition}");
            },
            //手指滑动时会触发此回调
            onPanUpdate: (DragUpdateDetails e) {
              //用户手指滑动时，更新偏移，重新构建
              setState(() {
                _left += e.delta.dx;
                _top += e.delta.dy;
              });
            },
            onPanEnd: (DragEndDetails e){
              //打印滑动结束时在x、y轴上的速度
              print("滑动结束：${e.velocity}");
            },
            onTap: () {
              setState(() {
                print("识别到onTap事件");
                _showOverlay(key);
              });
            },
          ),
        )
      ],
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

class MyPainterTest extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 在这里绘制你的图形，例如一个矩形
    final paint = Paint()..color = Colors.green;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}