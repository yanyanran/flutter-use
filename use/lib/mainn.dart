import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Rectangle Selector')),
        body: RectangleSelector(),
      ),
    );
  }
}

class RectangleSelector extends StatefulWidget {
  @override
  _RectangleSelectorState createState() => _RectangleSelectorState();
}

class _RectangleSelectorState extends State<RectangleSelector> {
  final List<Rect> rectangles = [
    Rect.fromLTWH(50, 50, 100, 100),
    Rect.fromLTWH(200, 50, 100, 100),
    Rect.fromLTWH(50, 200, 100, 100),
    Rect.fromLTWH(200, 200, 100, 100),
  ];

  Rect? selectedRectangle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RectangleGestureDetector(
          rectangles: rectangles,
          onRectangleSelected: (rect) {
            setState(() {
              selectedRectangle = rect;
              print('Selected rectangle: $rect');
            });
          },
          child: CustomPaint(
            painter: RectanglePainter(rectangles: rectangles),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: RectanglePainter(
              rectangles: rectangles,
              selectedRectangle: selectedRectangle,
            ),
          ),
        ),
      ],
    );
  }
}

class RectanglePainter extends CustomPainter {
  final List<Rect> rectangles;
  final Rect? selectedRectangle;

  RectanglePainter({required this.rectangles, this.selectedRectangle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    for (final rect in rectangles) {
      canvas.drawRect(rect, paint);
    }

    if (selectedRectangle != null) {
      final selectedPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRect(selectedRectangle!, selectedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class RectangleGestureDetector extends StatelessWidget {
  final List<Rect> rectangles;
  final ValueChanged<Rect?> onRectangleSelected;

  const RectangleGestureDetector({
    Key? key,
    required this.rectangles,
    required this.onRectangleSelected, required CustomPaint child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final tapPosition = details.localPosition;
        Rect? selectedRectangle;

        for (final rect in rectangles) {
          if (rect.contains(tapPosition)) {
            selectedRectangle = rect;
            break;
          }
        }

        onRectangleSelected(selectedRectangle);
      },
      child: CustomPaint(
        painter: RectanglePainter(rectangles: rectangles),
      ),
    );
  }
}