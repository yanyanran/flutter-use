import 'package:flutter/gestures.dart';
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
      home: ScaffoldRoute(),
    );
  }
}

class ScaffoldRoute extends StatefulWidget {
  @override
  _ScaffoldRouteState createState() => _ScaffoldRouteState();
}

class _ScaffoldRouteState extends State<ScaffoldRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Demo"),
      ),
      floatingActionButton: Drag(),  // 可拖拉按钮
    );
  }
}

class Drag extends StatefulWidget {
  const Drag();
  @override
  _DragState createState() => _DragState();
}

class _DragState extends State<Drag> with SingleTickerProviderStateMixin {
  double _top = 700.0; //按钮距顶部的偏移
  double _left = 320.0;//按钮距左边的偏移
  late OverlayEntry _overlayEntry;
  bool _isShowOverlay = false;

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          right: 87.6,  // 遮罩offset
          bottom: 112.1,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onLongPress: () { // 长按遮罩消失
              _overlayEntry.remove();
              _isShowOverlay = false;
            },
            child: Container(
              width: 100,  // 遮罩width、height
              height: 100,
              color: Colors.blueGrey.withOpacity(0.2),
              child: const Center(
                child: Text(
                  'Offset(87.6, 112.1)',
                  style: TextStyle(fontSize:9, color: Colors.white),
                ),
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
            child: CircleAvatar(child: Text("+")),  // 改成开/关
            onPanUpdate: (DragUpdateDetails e) { //用户手指滑动时，更新偏移重新构建按钮
              setState(() {
                _left += e.delta.dx;
                _top += e.delta.dy;
              });
            },
            onTap: () {
              if (_isShowOverlay) {
                _overlayEntry.remove();
                _isShowOverlay = false;
              } else {
                setState(() {
                  _showOverlay();
                  _isShowOverlay = true;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}