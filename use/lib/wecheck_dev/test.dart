import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const NAMES = {
  '三十六天罡' : [ '宋江', '卢俊义', '吴用', '公孙胜', '关胜' ],
  '七十二地煞' : [ '陈继真', '黄景元', '贾成', '呼颜', '鲁修德' ]
};

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

        body: ListView(
          children: _buildList(),
        ),
      ),
    );
  }
}

/// 创建列表 , 每个元素都是一个 ExpansionTile 组件
List<Widget> _buildList(){
  List<Widget> widgets = [];
  NAMES.keys.forEach((key) {
    widgets.add(_generateExpansionTileWidget(key, NAMES[key]));
  });
  return widgets;
}

/// 生成 ExpansionTile 组件 , children 是 List<Widget> 组件
Widget _generateExpansionTileWidget(tittle, List<String>? names){
  return ExpansionTile(
    title: Text(
      tittle,
      style: TextStyle(
          color: Colors.black54,
          fontSize: 20
      ),
    ),
    children: names!.map((name) => _generateWidget(name)).toList(),
  );
}

/// 生成 ExpansionTile 下的 ListView 的单个组件
Widget _generateWidget(name){
  /// 使用该组件可以使宽度撑满
  return FractionallySizedBox(
    widthFactor: 1,
    child: Container(
      height: 80,
      //width: 80,
      margin: EdgeInsets.only(bottom: 5),
      //margin: EdgeInsets.only(right: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.black),
      child: Text(
        name,
        style: TextStyle(
            color: Colors.yellowAccent,
            fontSize: 20
        ),
      ),
    ),
  );
}