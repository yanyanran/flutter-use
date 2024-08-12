import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("ListView 示例"),
        ),

        body: MapToList(),
      ),
    );
  }
}

class MapToList extends StatelessWidget {
  final Map<String, dynamic> res = {
    "isText": true,
    "typeName": 'RenderObject',
    "width": 100.0,
    "height": 200.0,
    "x": 50.0,
    "y": 100.0,
    "top": 150.0,
    "left": 20.0,
    "bottom": 300.0,
    "right": 40.0,
    "text_inherit": false,
    "text_family": 'Arial',
    "text_size": 16.0,
    "text_baseline": 'alphabetic',
    "text_decoration": 'underline',
    "text_weight": 'bold',
    "textColor": 0xFF0000FF,
    "radius": 10.0,
    "backgroundColor": 0xFFFFFF00,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        rootElementTree();
      },
      child: Container(
        color: Colors.yellow.withOpacity(0.5), // 半透明黄色遮罩
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2.5,
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height / 2.5),
        child: ListView.builder(  // detail info list
          itemCount: res.length,
          itemBuilder: (BuildContext context, int index) {
            final key = res.keys.elementAt(index);
            final value = res[key];
            return ListTile(
              title: Text('$key:'),
              subtitle: Text(value.toString()),
            );
          },
        ),
      ),
    );
  }
}

// void func() {
//   visitorChildRenderObject(Element element) {
//     if (element.renderObject is RenderBox && (element.renderObject as RenderBox).hasSize) {
//       var offset = (element.renderObject as RenderBox).localToGlobal(Offset.zero);
//       var widget = element.widget.runtimeType;
//       var size = (element.renderObject as RenderBox).size;
//       var depth = element.depth;  // 树的高度
//       var spaces = ' ' * depth * 1;
//       print("$spaces depth = $depth widget = $widget, render size = $size, offset = $offset");
//     }
//     element.visitChildren(visitorChildRenderObject);
//   }
//   WidgetsBinding.instance.rootElement?.visitChildren(visitorChildRenderObject);
// }

// 初始化一个全局map数组
// 数组元素map<depth, [widgetName, renderSize, renderOffset]>
List<Map<int, List<String>>> globalArray = [];

void rootElementTree() {
  visitorChildRenderObject(Element element) {
    if (element.renderObject is RenderBox && (element.renderObject as RenderBox).hasSize) {
      List<String> list = [];
      var depth = element.depth;  // 树的高度
      list.add((element.renderObject as RenderBox).localToGlobal(Offset.zero).toString()); // [0]
      list.add(element.widget.runtimeType.toString()); // [1]
      list.add((element.renderObject as RenderBox).size.toString()); // [2]
      // todo 给存map里去
      bool isExit = false;
      if(globalArray.isNotEmpty) {
        for(Map<int, List<String>> map in globalArray) {
          if(map.containsKey(depth)) {
            // 当前map已经存在，去下一个map看看
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

      var spaces = ' ' * depth * 1;
      print("$spaces depth = $depth widget = ${list[1]}, render size = ${list[2]}, offset = ${list[0]}");
    }
    element.visitChildren(visitorChildRenderObject);
  }
  WidgetsBinding.instance.rootElement?.visitChildren(visitorChildRenderObject);
  print("over-over-over!!!");
}