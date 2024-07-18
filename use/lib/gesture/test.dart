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
    return Listener(   // listener
      onPointerSignal: (event) {


      },
      child: GestureDetector(
        onTap: () => print("绿色单击"),
        onLongPress: () => print("绿色长按"),
        child: Container(
            width: 200,
            height: 200,
            color: Colors.green,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => print("红色单击"),
              onLongPress: () => print("红色长按"),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.red,
                child: Center(child: Text(_gesture)),
              ),
            )
        ),
      ),
    );
  }
}