import 'package:aa/tools/hitTestTools.dart' as tools;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
      home: ValueListenableRoute(),
    );
  }
}

// 确定用户点击的位置是否在列表范围内
Rect _inspector(Offset offset) {
  final tapPosition = offset;
  final renderObj = WidgetsBinding.instance.renderView;
  tools.WidgetInspectorState inn = tools.WidgetInspectorState();
  final resList = inn.hitTest(tapPosition, renderObj);
  var render = resList[0];
  var rect = render.semanticBounds;
  var transform = render.getTransformTo(null);
  print("【widget信息】rect信息: ${rect}, rect.x: ${transform.getTranslation().x}, rect.y: ${transform.getTranslation().y}");
  return rect;
}

// 定义一个ValueNotifier，当数字变化时会通知 ValueListenableBuilder
late ValueNotifier<Offset> _offset = ValueNotifier<Offset>(Offset.zero);

// 绘图
class RectanglePainter extends CustomPainter {
  final Rect rect;
  RectanglePainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// 大框架
class ValueListenableRoute extends StatefulWidget {
  const ValueListenableRoute({Key? key}) : super(key: key);
  @override
  State<ValueListenableRoute> createState() => _ValueListenableState();
}

class _ValueListenableState extends State<ValueListenableRoute> {
  @override
  Widget build(BuildContext context) {
    // 添加 + 按钮不会触发整个 ValueListenableRoute 组件的 build
    print('build');
    return Scaffold(
      appBar: AppBar(title: Text('ValueListenableBuilder 测试')),
      body: Stack(
        children: [List(), ValueListenableBuilder<Offset>(   // builder 方法只会在 offset 变化时被调用
        builder: (BuildContext context, Offset value, Widget? child) {
          if (value.dx == 0 && value.dy == 0)  {
            return CustomPaint(
              painter: RectanglePainter(rect: Rect.zero),
            );
          }
          Rect _rect = _inspector(_offset.value);
          // 重新渲染绘画
          return CustomPaint(
            painter: RectanglePainter(rect: _rect),
          );
        },
        valueListenable: _offset,
        child: const Text('点击了 ', textScaleFactor: 1.5),
      )],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        // todo
        onPressed: () {
          //icon Offset(24.1, 607.8)  rect信息: Rect.fromLTRB(0.0, 0.0, 360.0, 60.0), rect.x: 0.0, rect.y: 156.0
          //文字  Offset(125.0, 606.6)   rect信息: Rect.fromLTRB(0.0, 0.0, 328.0, 60.0), rect.x: 16.0, rect.y: 156.0
          _offset.value = Offset(125.0, 606.6);
        },

        // onPressed: () => GestureDetector(  // 点击后识别数值更新
        //   onTap: () {
        //     print("识别到tap");
        //   },
        //   onTapDown: (TapDownDetails details) {
        //     print("识别到point:${details.globalPosition}");
        //     // 更新offset数值，触发 ValueListenableBuilder 重新构建
        //     _offset.value = details.globalPosition;
        //   },
        // ),
      ),
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
    return SizedBox(
      height: 1000.0,
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
          }
      ),
    );
  }
}

