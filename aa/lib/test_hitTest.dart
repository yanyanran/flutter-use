
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyCustomControl hit test', (WidgetTester tester) async {
    int tapCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyCustomControl(
            onTap: () {
              tapCount++;
            },
          ),
        ),
      ),
    );

    // 模拟触摸事件
    await tester.tap(find.byType(MyCustomControl));
    await tester.pump();

    // 验证触摸事件是否与MyCustomControl相交
    expect(tapCount, 1);
  });
}

class MyCustomControl extends StatelessWidget {
  final VoidCallback onTap;
  MyCustomControl({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        color: Colors.red,
      ),
    );
  }
}