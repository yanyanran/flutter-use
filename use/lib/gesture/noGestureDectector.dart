import 'dart:async';
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
  late CustomGestureRecognizer _customGestureRecognizer;
  int _clickCount = 0;
  Timer? _doubleClickTimer;

  @override
  void initState() {
    super.initState();
    _customGestureRecognizer = CustomGestureRecognizer(
      onTap: (PointerEvent event) {
        setState(() {
          _clickCount++;
          if (_clickCount == 1) { // 单击
            _doubleClickTimer = Timer(Duration(milliseconds: 300), () {
              print('单击事件');
              _clickCount = 0;
            });
          } else if (_clickCount == 2) { // 双击
            _doubleClickTimer?.cancel();
            print('双击事件');
            _clickCount = 0;
          }
        });
      },
      onLongPress: (PointerEvent event) {
        print('长按事件');
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        _customGestureRecognizer.addAllowedPointer(event);
      },
      onPointerUp: (PointerUpEvent event) {
        _customGestureRecognizer.handleEvent(event);
      },
      child: Container(
        width: 200,
        height: 200,
        color: Colors.green,
        alignment: Alignment.center,
        child: Container(
          width: 100,
          height: 100,
          color: Colors.red,
          child: Center(child: Text('点击我')),
        ),
      ),
    );
  }
}

// 自定义Recognizer类
class CustomGestureRecognizer extends GestureRecognizer {
  final Function(PointerEvent) onTap;
  final Function(PointerEvent) onLongPress;

  int _downTime = 0;
  final int _longPressTimeout = 300; // 长按阈值，单位ms

  CustomGestureRecognizer({Object? debugOwner, required this.onTap, required this.onLongPress}) : super(debugOwner: debugOwner);

  @override
  void addAllowedPointer(PointerDownEvent event) {  // down
    super.addAllowedPointer(event);
    _downTime = event.timeStamp.inMilliseconds;
    Timer(Duration(milliseconds: _longPressTimeout), () {
    });
    }

  @override
  void handleEvent(PointerEvent event) {  // up
    if (event is PointerUpEvent) {
      int upTime = event.timeStamp.inMilliseconds;
      int duration = upTime - _downTime;

      if (duration < 300) {
        onTap?.call(event);
      } else {
        onLongPress?.call(event);
      }
    }
  }

  @override
  String get debugDescription => 'CustomGestureRecognizer';

  @override
  void acceptGesture(int pointer) {
    // TODO: implement acceptGesture
  }

  @override
  void rejectGesture(int pointer) {
    // TODO: implement rejectGesture
  }
}