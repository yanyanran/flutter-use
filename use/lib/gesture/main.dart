import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('手势识别')),
        body: Center(child: CustomWidget()),
      ),
    );
  }
}

class CustomWidget extends StatefulWidget {
  @override
  _CustomWidgetState createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  late TapGestureRecognizer _tapRecognizer;  // 手势识别器
  late LongPressGestureRecognizer _longPressRecognizer;
  String _gesture = '';
  String _winner = '';

  @override
  void initState() {  // 设置两种手势的回调
    super.initState();
    _tapRecognizer = TapGestureRecognizer()..onTap = (){
        setState((){
          _gesture = '单击';
          _winner = '单击';
        });
    };
    _longPressRecognizer = LongPressGestureRecognizer()..onLongPress = (){
        setState((){
          _gesture = '长按';
          _winner = '长按';
        });
    };
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    _longPressRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Element element;
    return Listener(   // listener
      onPointerSignal: (event) {
        print("【event】${event}");
        _tapRecognizer.onTap;
        if (_winner.isNotEmpty) {
          final debugOwner = _winner == '单击' ? _tapRecognizer.debugOwner : _longPressRecognizer.debugOwner;
          print('up控件信息：\n类型：${context.findRenderObject().runtimeType}\n代码创建位置：\n${debugOwner?.toString()}');
          print('堆栈跟踪：\n${StackTrace.current}');  // 获取到当前堆栈信息
          print('[up]${_winner}胜出');
        }
      },
      child: GestureDetector(
        onTap:_tapRecognizer.onTap,
        onLongPress: _longPressRecognizer.onLongPress,
        child: Container(
          width: 200,
          height: 200,
          color: Colors.green,
          alignment: Alignment.center,
          child: Container(
                width: 100,
                height: 100,
                color: Colors.red,
                child: Center(child: Text(_gesture)),
              ),
        ),
      ),
    );
  }
}

// 找出手势竞争者所属的控件
// 打印控件信息（如控件创建的代码位置）