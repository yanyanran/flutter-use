import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
      body: Center(child: CustomWidget()),
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

  void _showOverlay() {
    if (!(infoMap['w'] == null && infoMap['h'] == null) || !(infoMap['w'] == 0.0 && infoMap['h'] == 0.0)) {
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            right: 87.6,  // todo 控件offset
            bottom: 112.1,
            child: GestureDetector(
              onLongPress: () { // 长按遮罩消失
                _overlayEntry.remove();
                _isShowOverlay = false;
              },
              child: Container(
                  width: infoMap['w'],  // todo 控件width、height
                  height: infoMap['h'],
                  color: Colors.blueGrey.withOpacity(0.2),
                  child: GestureDetector(
                    onTap: () {
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
          onLongPress: () {
            _detailOverlayEntry.remove();
            _isShowDetailOverlay = false;
          },
          child: Container(
            color: Colors.black.withOpacity(0.5),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Text(  // todo debugOner Info
                '[WinnerInfo] Winner: ${infoMap['winner']}\n[WinnerInfo] Stack: ${infoMap['stack']}\n[WinnerInfo] Owner: ${infoMap['owner']}\n[WinnerInfo] OwnerCreateLocation: ${infoMap['location']}\n',
                style: TextStyle(fontSize: 11, color: Colors.white),
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
    if (_isShowOverlay) {
      setState(() {
        _overlayEntry.remove();
        _isShowOverlay = false;
      });
    } else {
      setState(() {
        infoMap = GestureArenaManager.GestureWinnerCallback();
        _showOverlay();
        _isShowOverlay = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(   // listener
      child: GestureDetector(
        onTap: () {
          print("绿色单击");
          if (_isOn) {  // 检查开启状态
            start();
          }// 关闭状态，什么都不做
        },
        onLongPress: () {
          print("绿色长按");
          if (_isOn) {
            start();
          }
        },
        child: Container(
            width: 200,
            height: 200,
            color: Colors.green,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                print("红色单击");
                if (_isOn) {
                  start();
                }
              },
              onLongPress: () {
                print("红色长按");
                if (_isOn) {
                  start();
                }
              },
              child: Container(
                width: 100,
                height: 100,
                color: Colors.red,
              ),
            )
        ),
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: _top,
          left: _left,
          child: GestureDetector(
            child: CircleAvatar(child: Text(_isOn ? "OFF" : "ON")),
            onPanUpdate: (DragUpdateDetails e) { // 用户手指滑动时重新构建按钮
              setState(() {
                _left += e.delta.dx;
                _top += e.delta.dy;
              });
            },
            onTap: () {
              _isOn = !_isOn;  // 更新状态
              setState(() {
                CircleAvatar(child: Text(_isOn ? "OFF" : "ON"));
              });
            },
          ),
        ),
      ],
    );
  }
}