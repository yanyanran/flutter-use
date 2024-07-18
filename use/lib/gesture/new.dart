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
        appBar: AppBar(title: Text('Custom Gesture Recognizer')),
        body: Center(child: customGestureDetector(
          onTap: () => print("22222222222222222222222222222222222222"),
          child: Container(
            width: 200,
            height: 200,
            color: Colors.red,
            alignment: Alignment.center,
            child: customGestureDetector(
              onTap: () => print("111111111111111111111111111111111111111111111111"),
              child: Container(
                width: 50,
                height: 50,
                color: Colors.grey,
              ),
            ),
          ),
        )),
      ),
    );
  }
}

class CustomTapGestureRecognizer extends TapGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    super.rejectGesture(pointer);
    // 直接宣布成功
    //super.acceptGesture(pointer);
  }
}

// 创建一个新的GestureDetector，用我们自定义的 CustomTapGestureRecognizer 替换默认的
RawGestureDetector customGestureDetector({
  GestureTapCallback? onTap,
  GestureTapDownCallback? onTapDown,
  Widget? child,
}) {
  return RawGestureDetector(
    child: child,
    gestures: {
      CustomTapGestureRecognizer:
      GestureRecognizerFactoryWithHandlers<CustomTapGestureRecognizer>(
            () => CustomTapGestureRecognizer(),
            (detector) {
          detector.onTap = onTap;
        },
      )
    },
  );
}