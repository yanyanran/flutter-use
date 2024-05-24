import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GestureDetectorTestRoute());
}

class GestureDetectorTestRoute extends StatefulWidget {
  @override
  _GestureDetectorTestRouteState createState() =>
      _GestureDetectorTestRouteState();
}

class _GestureDetectorTestRouteState extends State<GestureDetectorTestRoute> {
  final GlobalKey _key = GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home:
        Scaffold(  // 防止红屏
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text("GestureDetectorTest"),
          ),
          body: Center(
            child: GestureDetector(// 用GestureDetector对container组件进行手势识别
              // todo 添加矩形遮罩
              key: _key,
              child: Container(
                width: 200,
                height: 200,
                color: Colors.red,
                // alignment: Alignment.center,
                // child: Text(
                //   _operation,
                //   style: const TextStyle(
                //       color: Colors.white,
                //       fontSize: 14,
                //       decoration: TextDecoration.none),
                // ),
              ),
              onTap: () {
                RenderObject? _box = _key.currentContext?.findRenderObject();
                Offset? _offset = _box?.localToGlobal(Offset.zero);
                print('当前Widget的坐标为：${_offset.toString()}');
              }, //单击
              // onDoubleTap: () => updateText("onDoubleTap"), //双击
              // onLongPress: () => updateText("onLongPress"), //长按
            ),
          ),
        )
    );
  }

// //更新文本
// void updateText(String text) {
//   setState(() {
//     _operation = text;
//   });
// }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, required this.title}) : super(key: key);
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;  // 记录按钮点击总次数
//
//   void _incrementCounter() {
//     setState(() {  // 自增-> 调setState（重新build）
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) { // 构建build树
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(  // 按钮
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }