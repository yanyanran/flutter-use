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

// 大页面骨架
class ScaffoldRoute extends StatefulWidget {
  @override
  _ScaffoldRouteState createState() => _ScaffoldRouteState();
}

class _ScaffoldRouteState extends State<ScaffoldRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( //导航栏
        title: Text("Demo"),
      ),
      body: List(),  // globalKey传给列表
      floatingActionButton: Drag(),  // 可拖拉悬浮按钮  globalKey传给按钮
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
              "$index  列表标题",
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
  const Drag({super.key});

  @override
  _DragState createState() => _DragState();
}

class _DragState extends State<Drag> with SingleTickerProviderStateMixin {
  double _top = 700.0; //距顶部的偏移
  double _left = 320.0;//距左边的偏移
  late OverlayEntry _overlayEntry;
  HitTestResult hitTestResult = HitTestResult();

  // 全屏遮罩
  void _showOverlay() {
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
              // todo 确定用户点击的位置是否在列表范围内
              final tapPosition = details.globalPosition;
              WidgetsBinding.instance.renderView.hitTest(hitTestResult, position: tapPosition);

              // 获取最上层的组件
              var pathLen = hitTestResult.path.toList().length;
              final HitTestEntry topmostEntry = hitTestResult.path.toList()[pathLen - 1];
              final RenderView renderView = topmostEntry.target as RenderView;
              final RenderBox? renderBox = renderView.child;
              final Rect bounds = renderView.paintBounds;  // 边界
              final Size size = renderView.size;  // 大小
              final Offset? position = renderBox?.localToGlobal(Offset.zero);  // 位置

              print("【widget】大小：${size}, 边界：${bounds}, 位置：${position}");
              },
            onLongPress: () { // 长按遮罩消失
              _overlayEntry.remove();
              },
            child: Container(  // 全屏遮罩
              color: Colors.blueGrey.withOpacity(0.2),
              child: const Center(
                child: Text('识别模式', style: TextStyle(color: Colors.white, fontSize: 24)),
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
                _showOverlay();
              });
            },
          ),
        )
      ],
    );
  }
}