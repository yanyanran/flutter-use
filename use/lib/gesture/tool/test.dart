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

bool _isOn = false;
Map<String, dynamic> infoMap = <String, dynamic>{};

// 展示winner信息的遮罩控件
class ScaffoldRoute extends StatefulWidget {
  @override
  _ScaffoldRouteState createState() => _ScaffoldRouteState();
}

class _ScaffoldRouteState extends State<ScaffoldRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("手势竞争识别器"),
      ),
      floatingActionButton: Drag(),  // 可拖拉按钮
      body: List(),
    );
  }
}

// 手势识别控件
class CustomWidget extends StatefulWidget {
  @override
  _CustomWidgetState createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  late OverlayEntry _overlayEntry, _detailOverlayEntry;
  bool _isShowOverlay = false;
  bool _isShowDetailOverlay = false;

  void _showOverlay(double top,left,bottom,right) {
    if (!(infoMap['w'] == null && infoMap['h'] == null) || !(infoMap['w'] == 0.0 && infoMap['h'] == 0.0)) {
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            top: top,  // 控件offset
            left: left,
            right: right,
            bottom: bottom,
            child: GestureDetector(
              onTap: () { // 长按遮罩消失
                _overlayEntry.remove();
                _isShowOverlay = false;
              },
              child: Container(
                  width: infoMap['w'],  // 控件width、height
                  height: infoMap['h'],
                  color: Colors.blueGrey.withOpacity(0.6),
                  child: GestureDetector(
                    onLongPress: () {
                      _showDetailedOverlay(infoMap);
                    },
                  )
              ),
            ),
          );
        },
      );
      Overlay.of(context).insert(_overlayEntry);
    }
  }

  // 详情信息展示
  void _showDetailedOverlay(Map<String, dynamic> infoMap) {
    _detailOverlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            _detailOverlayEntry.remove();
            _isShowDetailOverlay = false;
          },
          child: Container(
            color: Colors.black.withOpacity(0.5),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  final key = infoMap.keys.elementAt(index);
                  final value = infoMap[key];

                  return Scrollbar( // 显示进度条
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text(
                                key,
                                style: TextStyle(fontSize: 13, color: Colors.white, decoration: TextDecoration.none),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              value,
                              style: TextStyle(fontSize: 10, color: Colors.white, decoration: TextDecoration.none),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_detailOverlayEntry); // 将全屏遮罩插入到Overlay中
    _isShowDetailOverlay = true; // 设置标志位表示全屏遮罩已显示
  }

  void start() {
    final resList = GestureBinding.debugHitTestResList;
    var transform = resList[0].target.getTransformTo(null);
    var X, Y, W, H, width, height, x, y;

    width = resList[0].target.semanticBounds.width.toDouble();
    height = resList[0].target.semanticBounds.height.toDouble();
    x = transform.getTranslation().x.toDouble();
    y = transform.getTranslation().y.toDouble();

    W = resList[resList.length - 3].target.semanticBounds?.width.toDouble();
    H = resList[resList.length - 3].target.semanticBounds?.height.toDouble();
    X = resList[resList.length - 3].target.getTransformTo(null).getTranslation().x.toDouble();
    Y = resList[resList.length - 3].target.getTransformTo(null).getTranslation().y.toDouble();

    var top = y - Y;
    var left = x - X;
    var bottom = (Y + H!) - (y + height);
    var right = (X + W!) - (x + width);

    if (_isShowOverlay) {
      setState(() {
        _overlayEntry.remove();
        _isShowOverlay = false;
      });
    } else {
      setState(() {
        infoMap = GestureArenaManager.GestureWinnerCallback();
        _showOverlay(top, left, bottom, right);
        _isShowOverlay = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(   // listener
      child: GestureDetector(
        onTapDown: (de) {
          if (_isOn) {  // 检查开启状态
            start();
          }// 关闭状态，什么都不做
        },
        onLongPressStart: (de) {
          if (_isOn) {
            start();
          }
        },
        child: ListView.builder(
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
            }),
      ),
    );
  }
}

// 按钮负责模式的开启/关闭
class Drag extends StatefulWidget {
  const Drag();
  @override
  _DragState createState() => _DragState();
}

class _DragState extends State<Drag> with SingleTickerProviderStateMixin {
  double _top = 700.0; //按钮距顶部的偏移
  double _left = 320.0;//按钮距左边的偏移
  late bool _isCheck = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: _top,
          left: _left,
          child: GestureDetector(
            child: CircleAvatar(child: Text(_isOn ? "ON" : "OFF")),
            onPanUpdate: (DragUpdateDetails e) { // 用户手指滑动时重新构建按钮
              setState(() {
                _left += e.delta.dx;
                _top += e.delta.dy;
              });
            },
            onTap: () {
              setState(() {
                CircleAvatar(child: Text(_isOn ? "ON" : "OFF"));
              });
              showDialog(  // 点击按钮弹出控制面板
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(  // showDialog内部组件动态更新时需要用StatefulBuilder
                      builder: (ctx, setState) {
                        return AlertDialog(
                          title: Text('控制面板'),
                          content: SwitchListTile(
                            value: _isCheck,
                            onChanged: (value) {
                              setState(() {
                                _isOn = !_isOn;  // 开关更新状态
                                if (_isOn) {
                                  GestureArenaManager.CheckWinnerDebugTool(true);
                                } else {
                                  GestureArenaManager.CheckWinnerDebugTool(false);
                                }
                                _isCheck = value;
                              });
                            },
                            title: Text('手势竞争排查工具', style: TextStyle(fontSize: 14)),
                          ),
                          actions: <Widget>[
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                Navigator.of(context).pop(ctx); // 关闭对话框
                              },
                            ),
                          ],
                        );
                      }
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

