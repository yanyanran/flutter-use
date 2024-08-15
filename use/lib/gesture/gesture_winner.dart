import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mm_foundation/monitor/route.dart';
import 'package:flutter_mmui/wecheck/inspector_tool.dart';

class WidgetInfo {
  double left = 0.0, right = 0.0, top = 0.0, bottom = 0.0, width = 0.0, height = 0.0;
}

// 按钮负责模式的开启/关闭
class WinnerDebugDragButton {
  bool _isOn = false;
  Map<String, dynamic> infoMap = <String, dynamic>{};
  double _top = 700.0, _left = 320.0;
  Map<String, List<String>> renderMap = {};  // 全局的列表信息kv对
  Map<dynamic, dynamic> detailMap = {};      // 全局的属性信息
  List<Widget> widgetList = [];  // 全局的widget列表
  List<Map<int, List<String>>> globalArray = [];  // 树的层级列表 - 数组元素map<depth, [widgetName, renderSize, renderOffset]>
  late RenderObject targetRender;
  List<RenderObject?> renderList = [];

  // 手势winner
  late OverlayEntry _buttonOverlayEntry, _overlayEntry, _detailOverlayEntry;
  bool _isWinnerOn = false, _isWinnerShowOverlay = false;
  // weCheck
  late OverlayEntry _widgetTreeEntry, _fullScreenOverlayEntry, _attributesOverlayEntry;
  bool _isWecheckOn = false, _isWecheckShowOverlay = false, _isHitTestAreaShowOverlay = false;

  NavigatorState? navigator;
  OverlayState? get overlay => navigator?.overlay;

  void bind() {
    bool _isShowDialog = false;
    navigator = RouteMonitor.instance().navigator;
    _buttonOverlayEntry = OverlayEntry(builder: (context) {
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
                _buttonOverlayEntry.markNeedsBuild();
              },
              onTap: () {
                if(!_isShowDialog) {
                  showDialog(  // 点击按钮弹出控制面板
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                          builder: (ctx, setState) {
                            return AlertDialog(
                              title: Text('控制面板'),
                              content: Column(
                                  children: [
                                    SwitchListTile(
                                      value: _isWinnerOn,
                                      onChanged: (value) {
                                        setState(() {
                                          _isOn = !_isOn;  // 开关更新状态
                                          if (_isOn) {
                                            _isShowDialog = true;
                                            GestureArenaManager.CheckWinnerDebugTool(true);
                                            GestureArenaManager.SetWinnerCallback(winnerStart);
                                          } else {
                                            GestureArenaManager.CheckWinnerDebugTool(false);
                                          }
                                          _isWinnerOn = value;
                                        });
                                      },
                                      title: Text('手势竞争排查工具', style: TextStyle(fontSize: 14)),
                                    ),
                                    SwitchListTile(
                                      value: _isWecheckOn,
                                      onChanged: (value) {
                                        setState(() {
                                          _isWecheckOn = value;
                                          if(_isWecheckOn) {
                                            // 关闭控制面板，加一个全屏遮罩
                                            Navigator.of(context).pop(ctx);
                                            _isShowDialog = false;
                                            _isWecheckOn = false;
                                            _fullScreenOverlayEntry = OverlayEntry(
                                              builder: (context) {
                                                return Positioned(
                                                  top: 0,
                                                  left: 0,
                                                  right: 0,
                                                  bottom: 0,
                                                  child: GestureDetector(
                                                    onTapDown: (details) {
                                                      weCheckStart(details.globalPosition);
                                                    },
                                                    onLongPress: () {
                                                      if(RouteMonitor.instance().navigator?.overlay != null) {
                                                        _fullScreenOverlayEntry.remove();
                                                      }
                                                    },
                                                    child: Container(  // 全屏遮罩
                                                      color: Colors.blueGrey.withOpacity(0.6),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                            overlay?.insert(_fullScreenOverlayEntry);
                                          } else {
                                            _isShowDialog = true;
                                          }
                                        });
                                      },
                                      title: Text('Wecheck工具', style: TextStyle(fontSize: 14)),
                                    ),
                                  ]
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
    overlay?.insert(_buttonOverlayEntry);
  }

  void winnerStart() {
    final resList = GestureBinding.debugHitTestResList;
    WidgetInfo info = calculateFunc("winner", GestureArenaManager, resList[resList.length - 3].target);

    if (!_isWinnerShowOverlay) {
      infoMap = <String, String> {
        'Winner': GestureArenaManager.DebugWinner,
        'Owner': GestureArenaManager.DebugOwner,
        'Location': GestureArenaManager.DebugOwnerCreator,
        'Stack': GestureArenaManager.DebugStackInfo,
      };
      _showOverlay("winner", info.top, info.left, info.bottom, info.right, info.width, info.height);
    }
  }

  void weCheckStart(Offset position) {
    renderMap.clear();
    if (!_isWecheckShowOverlay) {
      final resList = InspectorTool.hitTest(position, WidgetsBinding.instance.renderView.child!);
      targetRender = resList[resList.length - 1];
      detailMap = InspectorTool.inspector("normal", position, [], EmptyRenderObject());
      int i = 0;
      for (final render in resList) {
        if (render is RenderBox && (render as RenderBox).hasSize) {  // 和rootElement结果对齐
          renderMap['[$i]' + render.runtimeType.toString()] = [
            (render.debugCreator as DebugCreator).element.widget.runtimeType.toString(),
            ((render.debugCreator as DebugCreator).element.renderObject as RenderBox).size.toString(),  // size
            'Key: ' + (render.debugCreator as DebugCreator).element.widget.key.toString(),
            (render as RenderBox).localToGlobal(Offset.zero).toString()   // offset
          ];
        }
        i++;
      }
      WidgetInfo info = calculateFunc("weCheck", resList[0], resList[resList.length - 1]);
      _showOverlay("weCheck", info.top, info.left, info.bottom, info.right, info.width, info.height);
      _showWidgetTreeDevOverlay(renderMap, position, resList);
    }
  }

  WidgetInfo calculateFunc(String type, dynamic first, RenderObject last) {
    WidgetInfo info = WidgetInfo();
    var X, Y, W, H, width, height, x, y;

    if(type == "weCheck") {
      width = first.semanticBounds.width.toDouble();
      height = first.semanticBounds.height.toDouble();
      x = first.getTransformTo(null).getTranslation().x.toDouble();
      y = first.getTransformTo(null).getTranslation().y.toDouble();
    } else if (type == "winner") {
      width = GestureArenaManager.wight;
      height = GestureArenaManager.height;
      x = GestureArenaManager.x;
      y = GestureArenaManager.y;
    }

    W = last.semanticBounds.width.toDouble();
    H = last.semanticBounds.height.toDouble();
    X = last.getTransformTo(null).getTranslation().x.toDouble();
    Y = last.getTransformTo(null).getTranslation().y.toDouble();

    info.top = y - Y;
    info.left = x - X;
    info.bottom = (Y + H!) - (y + height);
    info.right = (X + W!) - (x + width);

    return info;
  }

  // 可复用的接口，用来绘制所属控件的遮罩
  void _showOverlay(String type, double top, left, bottom, right, w, h) {
    if (!(w == null && h == null) || !(w == 0.0 && h == 0.0)) {
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            top: top,  // 控件offset
            left: left,
            right: right,
            bottom: bottom,
            child: GestureDetector(
              onTap: () { // 点击遮罩消失
                if(RouteMonitor.instance().navigator?.overlay != null) {
                  _overlayEntry.remove();
                }
                if(type == "winner") {
                  _isWinnerShowOverlay = false;
                } else if (type == "weCheck") {
                  _isWecheckShowOverlay = false;
                } else if (type == "weCheckHitTest") {
                  _isHitTestAreaShowOverlay = false;
                }
              },
              child: Container(
                  width: w,
                  height: h,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.6),
                    border: Border.all(
                      color: Colors.black, // 描边
                      width: 1,
                    ),
                  ),
                  child: GestureDetector(
                    onLongPress: () {
                      if(type == "winner") {
                        _showDetailedOverlay(infoMap);
                      }
                    },
                  )
              ),
            ),
          );
        },
      );
      RouteMonitor.instance().navigator?.overlay?.insert(_overlayEntry);
      if(type == "winner") {
        _isWinnerShowOverlay = true;
      } else if (type == "weCheck") {
        _isWecheckShowOverlay = true;
      } else if (type == "weCheckHitTest") {
        _isHitTestAreaShowOverlay = true;
      }
    }
  }

  // 详情信息展示
  void _showDetailedOverlay(Map<String, dynamic> infoMap) {
    GestureArenaManager.CheckWinnerDebugTool(false);
    _detailOverlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            if(RouteMonitor.instance().navigator?.overlay != null) {
              _detailOverlayEntry.remove();
              GestureArenaManager.CheckWinnerDebugTool(true);
            }
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
    RouteMonitor.instance().navigator?.overlay?.insert(_detailOverlayEntry);
  }

  void _showWidgetTreeDevOverlay(Map<String, List<String>> resMap, Offset position, List<RenderObject> hitTestResultList) {
    _widgetTreeEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent, // 要设成透明
        child: Stack(
          children: [
            GestureDetector(
              onLongPress: () {
                if(RouteMonitor.instance().navigator?.overlay != null) {
                  _widgetTreeEntry.remove();
                  _isHitTestAreaShowOverlay = false;
                }
              },
              child: Container(
                  color: Colors.yellow.withOpacity(0.5), // 半透明黄色遮罩
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.5,
                  margin: EdgeInsets.only(top: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 2.5),
                  child: ListView(
                    children: _buildList(resMap, hitTestResultList),
                  )
              ),
            ),
            Positioned( // 添加"detail"按钮
              top: (MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 2.6),
              right: 30,
              child: GestureDetector(
                onTap: () {
                  _attributesOverlayEntry = OverlayEntry(
                    builder: (context) => Material(
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onLongPress: () {
                              if(RouteMonitor.instance().navigator?.overlay != null) {
                                _attributesOverlayEntry.remove();
                                //_isHitTestAreaShowOverlay = false;
                              }
                            },
                            child: Container(
                              color: Colors.black,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 2.5,
                              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 2.5),
                              child: ListView.builder(  // 属性信息
                                itemCount: detailMap.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final key = detailMap.keys.elementAt(index);
                                  final value = detailMap[key];
                                  return ListTile(
                                    title: Text('$key:', style: TextStyle(color: Colors.white, fontSize: 18)),
                                    subtitle: Text(value.toString(), style: TextStyle(color: Colors.white70, fontSize: 16)),
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                  RouteMonitor.instance().navigator?.overlay?.insert(_attributesOverlayEntry);
                },
                child: Text('detail', style: TextStyle(color: Colors.blue, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
    RouteMonitor.instance().navigator?.overlay?.insert(_widgetTreeEntry);
  }

  // 半屏遮罩列表构建
  /// resMap【[0]renderName，[widgetName, widgetKey]】 - hitTest结果集
  List<Widget> _buildList(Map<String, List<String>> resMap, List<RenderObject> hitTestResultList){
    List<Widget> widgets = [];
    String title = '', size = '', value = '', offset = '';
    var re;

    rootElementTree();
    resMap.keys.forEach((key) {
      int i = 0;

      for (final render in hitTestResultList) {
        var res = removePrefix(key);
        if (res[0] == render.runtimeType.toString() && int.parse(res[1]) == i) {
          title = renderMap["[$i]" + render.runtimeType.toString()]![0];  // widgetName
          size = renderMap["[$i]" + render.runtimeType.toString()]![1];   // widgetSize
          value = renderMap["[$i]" + render.runtimeType.toString()]![2];  // widgetKey
          offset = renderMap["[$i]" + render.runtimeType.toString()]![3]; // offset
          // 拿到的renderObject和总树匹配，得到对应depth
          for (Map<int, List<String>> map in globalArray) {
            for (int key in map.keys) {
              List<String> v = map[key]!;
              if(v[0] == offset && v[1] == title && v[2] == size) {  // todo[删] widgetName、size、offset确定一个widget
                title = '[$key]' + title;  // key-> depth
              }
            }
          }
          re = render;
          break;
        }
        i++;
      }
      widgets.add(_generateExpansionTileWidget(title, value, hitTestResultList, re));
    });
    return widgets;
  }

  Widget _generateExpansionTileWidget(tittle, value, List<RenderObject> hitTestResultList, RenderObject render){
    return GestureDetector(
      onTap: () {
        if (_isWecheckShowOverlay || _isHitTestAreaShowOverlay) {
          if(RouteMonitor.instance().navigator?.overlay != null) {
            _overlayEntry.remove();
            _isWecheckShowOverlay = false;
            _isHitTestAreaShowOverlay = false;
          }
        }
        WidgetInfo info = calculateFunc("weCheck", render, hitTestResultList[hitTestResultList.length - 1]);
        _showOverlay("weCheckHitTest", info.top, info.left, info.bottom, info.right, info.width, info.height);
        detailMap = InspectorTool.inspector("self", const Offset(0, 0), hitTestResultList, render); // 更新detail
      },
      child: ExpansionTile(
          title: Text(
            tittle,
            style: TextStyle(
                color: Colors.black54,
                fontSize: 16
            ),
          ),
          children:_generateWidget(value)),
    );
  }

  List<Widget> _generateWidget(name){
    return [FractionallySizedBox(
      widthFactor: 1,
      child: Container(
        height: 26,
        margin: EdgeInsets.only(right: 5),
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(color: Colors.black12),
        child: Text(
          '    ' + name,
          style: TextStyle(
              color: Colors.yellowAccent,
              fontSize: 12
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 5),
      ),
    )];
  }

  // 可以拿到树结构的层级depth
  void rootElementTree() {
    visitorChildRenderObject(Element element) {
      if (element.renderObject is RenderBox && (element.renderObject as RenderBox).hasSize) {
        List<String> list = [];
        var depth = element.depth;
        list.add((element.renderObject as RenderBox).localToGlobal(Offset.zero).toString()); // [0]
        list.add(element.widget.runtimeType.toString()); // [1]
        list.add((element.renderObject as RenderBox).size.toString()); // [2]

        //renderList.add(element.renderObject);
        // 整体树存map
        bool isExit = false;
        if(globalArray.isNotEmpty) {
          for(Map<int, List<String>> map in globalArray) {
            if(map.containsKey(depth)) {
              // 当前map已经存在，去下个map看看
            } else {  // 不存在直接存
              map[depth] = list;
              isExit = true;
              break;
            }
          }
        }
        if(!isExit) {  // 数组中任何一个map都没有-> 在globalArray中新开一个map存
          globalArray.add({
            depth: list
          });
        }
        /// print
        var spaces = ' ' * depth * 1;
        print("$spaces depth = $depth widget = ${list[1]}, render size = ${list[2]}, offset = ${list[0]}");
      }
      element.visitChildren(visitorChildRenderObject);
    }
    WidgetsBinding.instance.rootElement?.visitChildren(visitorChildRenderObject);
  }
}

// title名解析，移除列表项前面的方框和数字
List<String> removePrefix(String input) {
  final match = RegExp(r'^\[(\d+)\]').firstMatch(input);
  if (match != null) {
    String number = match.group(1)!;
    RegExp regExp = RegExp(r'\[\d+\]'); // 正则表达式匹配方括号和数字
    String result = input.replaceAll(regExp, '');
    return [result, number];
  }
  return ['', '-1'];
}