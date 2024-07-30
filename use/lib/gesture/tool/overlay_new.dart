import 'dart:js';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// 按钮负责模式的开启/关闭
class WinnerDebugDragButton {
  bool _isOn = false;
  Map<String, dynamic> infoMap = <String, dynamic>{};

  double _top = 700.0, _left = 320.0;
  late OverlayEntry _butttonOverlayEntry, _overlayEntry, _detailOverlayEntry;
  bool _isCheck = false, _isShowOverlay = false, _isShowDetailOverlay = false;

  NavigatorState? navigator;
  OverlayState? get overlay => navigator?.overlay;

  void bind({BuildContext? context}) {
    bool _isShowDialog = false;
    _butttonOverlayEntry = OverlayEntry(builder: (context) {
      return Stack(
        children: <Widget>[
          Positioned(
            top: _top,
            left: _left,
            child: GestureDetector(
              child: CircleAvatar(child: Text(_isOn ? "ON" : "OFF")),
              onPanUpdate: (DragUpdateDetails e) { // 用户手指滑动时重新构建按钮
                _left += e.delta.dx;
                _top += e.delta.dy;
                _butttonOverlayEntry.markNeedsBuild();
              },
              onTap: () {
                if(!_isShowDialog) {
                  _isShowDialog = true;
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
                                      GestureArenaManager.SetWinnerCallback(start);
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
                                    Navigator.of(context).pop(ctx); // 关闭控制面板
                                    _isShowDialog = false;
                                  },
                                ),
                              ],
                            );
                          }
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      );
    });
    overlay?.insert(_butttonOverlayEntry);
  }

  void start() {
    final resList = GestureBinding.debugHitTestResList;
    var X, Y, W, H, width, height, x, y, top, bottom, left, right;

    if(resList[0].target.runtimeType is! TextSpan) {  // todo 暂时做过滤
      width = resList[0].target.semanticBounds.width.toDouble();
      height = resList[0].target.semanticBounds.height.toDouble();
      x = resList[0].target.getTransformTo(null).getTranslation().x.toDouble();
      y = resList[0].target.getTransformTo(null).getTranslation().y.toDouble();
      W = resList[resList.length - 3].target.semanticBounds?.width.toDouble();
      H = resList[resList.length - 3].target.semanticBounds?.height.toDouble();
      X = resList[resList.length - 3].target.getTransformTo(null).getTranslation().x.toDouble();
      Y = resList[resList.length - 3].target.getTransformTo(null).getTranslation().y.toDouble();
      top = y - Y;
      left = x - X;
      bottom = (Y + H!) - (y + height);
      right = (X + W!) - (x + width);

      if (!_isShowOverlay) {
        //   if(RouteMonitor.instance().navigator?.overlay != null) {
        //     _overlayEntry.remove();
        //   }
        //   _isShowOverlay = false;
        //   //_overlayEntry.markNeedsBuild();
        // } else {
        //infoMap = GestureArenaManager.GestureWinnerCallback();
        late DebugCreator? obj = ((resList[0].target as RenderObject).debugCreator as DebugCreator);
        infoMap = <String, String> {
          'Winner': GestureArenaManager.DebugWinner.toString(),
          'Owner': obj.element.widget.toString(),
          'Location': obj.element.widget.widgetLocation(),
          'Stack': GestureArenaManager.DebugStackInfo,
        };
        _showOverlay(top, left, bottom, right,width,height);
        //_overlayEntry.markNeedsBuild();
      }
    }
  }

  void _showOverlay(double top,left,bottom,right,w,h) {
    if (!(w == null && h == null) || !(w == 0.0 && h == 0.0)) {
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            top: top,  // 控件offset
            left: left,
            right: right,
            bottom: bottom,
            child:
            GestureDetector(
              onTap: () { // 点击遮罩消失
                _overlayEntry.remove();
                _isShowOverlay = false;
                //_overlayEntry.markNeedsBuild();
              },
              child:
              Container(
                // width: infoMap['w'],  // 控件width、height
                // height: infoMap['h'],
                  width: w,
                  height: h,
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
      Overlay.of(context as BuildContext).insert(_overlayEntry); // 将全屏遮罩插入到Overlay中
      _isShowOverlay = true;
    }
  }

  // 详情信息展示
  void _showDetailedOverlay(Map<String, dynamic> infoMap) {
    GestureArenaManager.CheckWinnerDebugTool(false);
    _detailOverlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            _detailOverlayEntry.remove();
            GestureArenaManager.CheckWinnerDebugTool(true);
            _isShowDetailOverlay = false;
          },
          child: Container(
            color: Colors.black.withOpacity(0.5),
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height,
            child: Center(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  final key = infoMap.keys.elementAt(index);
                  final value = infoMap[key];
                  print('[wwwwinerInfo] ${key}: ${value}');

                  return Scrollbar(
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text(
                                key,
                                style: TextStyle(fontSize: 13,
                                    color: Colors.white,
                                    decoration: TextDecoration.none),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              value,
                              style: TextStyle(fontSize: 10,
                                  color: Colors.white,
                                  decoration: TextDecoration.none),
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
    Overlay.of(context as BuildContext).insert(_detailOverlayEntry); // 将全屏遮罩插入到Overlay中
    _isShowDetailOverlay = true; // 设置标志位表示全屏遮罩已显示
  }
}