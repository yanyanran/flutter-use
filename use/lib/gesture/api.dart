import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'tool/overlay.dart';

// 自己实现GestureRecognizer替代GestureDetector，无法获取常规形态debugOwner
class ScaffoldRouteOwner extends StatefulWidget {
  @override
  _ScaffoldRouteState createState() => _ScaffoldRouteState();
}

class _ScaffoldRouteState extends State<ScaffoldRouteOwner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom Gesture Recognizer')),
      //floatingActionButton: Drag(),  // 可拖拉按钮
      body: Center(child: customGestureDetector(
        onTap: () => print("【绿色单击】"),
        onDoubleTap: () => print("【绿色双击】"),
        onLongPress: () => print("【绿色长按】"),
        child: Container(
          width: 200,
          height: 200,
          color: Colors.green,
          alignment: Alignment.center,
          child: customGestureDetector(
            onTap: () => print("【红色单击】"),
            onDoubleTap: () => print("【红色双击】"),
            onLongPress: () => print("【红色长按】"),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
          ),
        ),
      )),
    );
  }
}

class CustomTapGestureRecognizer extends TapGestureRecognizer {
  CustomTapGestureRecognizer({Object? debugOwner = "CustomTapGestureRecognizer"}) : super(debugOwner: debugOwner);

  @override
  void rejectGesture(int pointer) {
    super.rejectGesture(pointer);
  }
}

class CustomDoubleTapGestureRecognizer extends DoubleTapGestureRecognizer {
  CustomDoubleTapGestureRecognizer({Object? debugOwner = "CustomDoubleTapGestureRecognizer"}) : super(debugOwner: debugOwner);

  @override
  void rejectGesture(int pointer) {
    super.rejectGesture(pointer);
  }
}

class CustomLongPressGestureRecognizer extends LongPressGestureRecognizer {
  CustomLongPressGestureRecognizer({Object? debugOwner = "CustomLongPressGestureRecognizer"}) : super(debugOwner: debugOwner);

  @override
  void rejectGesture(int pointer) {
    super.rejectGesture(pointer);
  }
}

RawGestureDetector customGestureDetector({
  GestureTapCallback? onTap,
  GestureDoubleTapCallback? onDoubleTap,
  GestureLongPressCallback? onLongPress,
  Widget? child,
}) {
  final creationLocation = '${DateTime.now().toIso8601String()}';
  return RawGestureDetector(
    child: child,
    gestures: {
      CustomTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<CustomTapGestureRecognizer>(
            () => CustomTapGestureRecognizer(debugOwner: CustomDebugOwner(creationLocation: creationLocation)),
            (detector) {
          detector.onTap = onTap;
        },
      ),
      CustomDoubleTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<CustomDoubleTapGestureRecognizer>(
            () => CustomDoubleTapGestureRecognizer(debugOwner: CustomDebugOwner(creationLocation: creationLocation)),
            (detector) {
          detector.onDoubleTap = onDoubleTap;
        },
      ),
      CustomLongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<CustomLongPressGestureRecognizer>(
            () => CustomLongPressGestureRecognizer(debugOwner: CustomDebugOwner(creationLocation: creationLocation)),
            (detector) {
          detector.onLongPress = onLongPress;
        },
      ),
    },
  );
}

class CustomDebugOwner {
  final String creationLocation;
  CustomDebugOwner({required this.creationLocation});
}