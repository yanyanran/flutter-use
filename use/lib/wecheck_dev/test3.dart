import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: AppHome(),
    ),
  );
}

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: TextButton(
          onPressed: () {
            rootElementTree();
          },
          child: const Text('Dump Widget Tree'),
        ),
      ),
    );
  }
}

void func1() {
  visitorChildRenderObject(Element element) {
    if (element.renderObject is RenderBox && (element.renderObject as RenderBox).hasSize) {
      var offset = (element.renderObject as RenderBox).localToGlobal(Offset.zero);
      var widget = element.widget.runtimeType;
      var size = (element.renderObject as RenderBox).size;
      var depth = element.depth;  // 树的高度
      var spaces = ' ' * depth * 1;
      print("$spaces depth = $depth widget = $widget, render size = $size, offset = $offset");
    }
    element.visitChildren(visitorChildRenderObject);
  }
  WidgetsBinding.instance.rootElement?.visitChildren(visitorChildRenderObject);
}

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