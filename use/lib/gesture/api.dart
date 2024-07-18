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
      ),
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