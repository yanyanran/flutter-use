import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import './tools/hitTestTools.dart' as tools;

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

// 绘图
class RectanglePainter extends CustomPainter {
  final ValueListenable<Rect> rect;
  RectanglePainter({required this.rect}) : super(repaint: rect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect.value, paint);
    }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

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
      appBar: AppBar(
        title: Text("Demo"),
      ),
      body: Stack(
        children: [List()],
      ),
      floatingActionButton: Drag(key),
    );
  }
}

class List extends StatefulWidget {
  List({super.key});

  @override
  State<List> createState() => _ListState();
}

class _ListState extends State<List> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 20,
        itemExtent: 60.0, //强制高度为50.0
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: const Icon(Icons.people, color: Colors.blue),
            title: Text(
              "$index  列表标题----",
              style: TextStyle(color: Colors.blue),
            ),
            trailing: const Icon(
              Icons.keyboard_arrow_right,
              color: Colors.blue,
            ),
            hoverColor: Colors.blue,
            focusColor: Colors.blue,
            autofocus: true,
            onTap: () {
              print("$index");
            },

          );
        });
  }
}

// 可拖拉按钮
class Drag extends StatefulWidget {
  const Drag(GlobalKey<_DragState> key);

  @override
  _DragState createState() => _DragState();
}

class _DragState extends State<Drag> with SingleTickerProviderStateMixin {
  double _top = 700.0; //距顶部的偏移
  double _left = 320.0;//距左边的偏移
  late OverlayEntry _overlayEntry;

  // 确定用户点击的位置是否在列表范围内【重写hitTest】
  Rect _inspector(TapDownDetails details) {
    final tapPosition = details.globalPosition;
    final renderObj = WidgetsBinding.instance.renderView;
    tools.WidgetInspectorState inn = tools.WidgetInspectorState();
    final resList = inn.hitTest(tapPosition, renderObj);
    var render = resList[0];

    // if (render is RenderParagraph) {
    //   var textColor = render.text.style?.color;
    //   var text = render.text;
    //   print("识别到文字：${text}, 文字颜色：${textColor}");
    // }

    var rect = render.semanticBounds;
    var transform = render.getTransformTo(null);
    print("-------【widget信息】rect信息: ${rect}, rect.x: ${transform.getTranslation().x}, rect.y: ${transform.getTranslation().y}--------");
    return rect;
  }

  // 测试widgetsBinding的renderView
  void _showOverlay(GlobalKey<_DragState> key) {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            //onPanUpdate: rectPainter.updateRect(rect),
            behavior: HitTestBehavior.translucent,
            onTap: () {
              print("识别到遮罩层onTap");
            },
            onTapDown: (TapDownDetails details) {
              print("识别到point:${details.globalPosition}");
              var rect = _inspector(details);
              // 更新RectanglePainter的矩形信息
              final ValueNotifier<Rect> _rect = ValueNotifier<Rect>(rect);
              CustomPaint(
                painter: RectanglePainter(rect: _rect),
                size: Size(500, 500),
              );
            },
            onLongPress: () {
              _overlayEntry.remove();
            },
            child: Container(
              color: Colors.blueGrey.withOpacity(0.2),
              child: Center(
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
      children:<Widget>[
        Positioned(
          top: _top,
          left: _left,
          child: GestureDetector(
            child: CircleAvatar(child: Text("+")),
            // onPanDown: (DragDownDetails e) {
            //   print("用户手指按下：${e.globalPosition}");
            // },
            onTapDown: (TapDownDetails details) {
              print("识别到point:${details.globalPosition}");
            },
            onPanUpdate: (DragUpdateDetails e) {
              setState(() {  //用户手指滑动时，更新偏移，重新构建
                _left += e.delta.dx;
                _top += e.delta.dy;
              });
            },
            onPanEnd: (DragEndDetails e){
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