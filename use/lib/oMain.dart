import 'package:flutter/material.dart';

void main() {
  runApp(CloseTap());
}

class CloseTap extends StatefulWidget {
  @override
  _CloseTapTapState createState() => _CloseTapTapState();
}

class _CloseTapTapState extends State<CloseTap> with WidgetsBindingObserver {
  List<Offset> clickPositions = [];
  void _onAfterRendering(Duration timeStamp) {
    RenderObject? renderObject = context.findRenderObject();
    Size? size = renderObject?.paintBounds.size;
    var vector3 = renderObject?.getTransformTo(null).getTranslation();
    CommonUtils.showChooseDialog(context, size!, vector3);
  }

  @override
  Widget build(BuildContext context) {
    //  获取最小矩形的坐标
    double? minX, minY, maxX, maxY;
    if(clickPositions.isNotEmpty) {
      minX = clickPositions.map((e) => e.dx).reduce((value, element) => value < element ? value : element);
      minY = clickPositions.map((e) => e.dy).reduce((value, element) => value < element ? value : element);
      maxX = clickPositions.map((e) => e.dx).reduce((value, element) => value > element ? value : element);
      maxY = clickPositions.map((e) => e.dy).reduce((value, element) => value > element ? value : element);
    }

    return MaterialApp(
      home:
      Scaffold(
        key: GlobalKey<ScaffoldState>(),
        appBar: AppBar(
          title: Text('lalalalalal'),
        ),
        body: Center(
          child: GestureDetector(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: CustomPaint(
                painter: RectanglePainter(
                  minX: minX,
                  minY: minY,
                  maxX: maxX,
                  maxY: maxY,
                ),
              ),
            ),
            onTapDown: (TapDownDetails details) {
              // WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
              setState(() {
                clickPositions.add(details.localPosition);
              });
            },
          ),
        ),
      ),
    );
  }
}

class RectanglePainter extends CustomPainter {
  late final double? minX;
  late final double? minY;
  late final double? maxX;
  late final double? maxY;

  RectanglePainter({
    this.minX,
    this.minY,
    this.maxX,
    this.maxY,
});

  @override
  void paint(Canvas canvas, Size size) {
    if(minX != null && minY != null && maxX != null && maxY != null) {
      final paint = Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

      final rect = Rect.fromLTRB(minX!, minY!, maxX!, maxY!);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}

class CommonUtils {
  static showChooseDialog(BuildContext context, Size size, var vector3) {
    final double wx = size.height;
    final double dx = vector3[0];
    final double dy = vector3[1];
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Text(''),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                Positioned(
                  left: 10.0,
                  top: dy < h / 2 ? dy + wx / 2 : null,
                  bottom: dy < h / 2 ? null : (h - dy + wx / 2),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                      color: Colors.white,
                    ),
                    width: w - 20.0,
                    child: GestureDetector(
                      child: const Column(
                        children: <Widget>[
                          ListTile(
                              leading: Icon(Icons.highlight_off),
                              title: Text('不感兴趣'),
                              subtitle: Text('减少这类内容')),
                          Divider(),
                          ListTile(
                              leading: Icon(Icons.error_outline),
                              title: Text('反馈垃圾内容'),
                              subtitle: Text('低俗、标题党等')),
                          Divider(),
                          ListTile(
                              leading: Icon(Icons.not_interested),
                              title: Text('屏蔽'),
                              subtitle: Text('请选择屏蔽的广告类型')),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.help_outline),
                            title: Text('为什么看到此广告'),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: dx - 10.0,
                  top: dy < h / 2 ? dy - wx / 2 : null,
                  bottom: dy < h / 2 ? null : (h - dy - wx / 2),
                  child: ClipPath(
                    clipper: Triangle(dir: dy - h / 2),
                    child: Container(
                      width: 30.0,
                      height: 30.0,
                      color: Colors.white,
                      child: null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Triangle extends CustomClipper<Path> {
  double dir;
  Triangle({required this.dir});
  @override
  Path getClip(Size size) {
    var path = Path();
    double w = size.width;
    double h = size.height;
    if (dir < 0) {
      path.moveTo(0, h);
      path.quadraticBezierTo(0, 0, w * 2 / 3, 0);
      path.quadraticBezierTo(w / 4, h / 2, w, h);
    } else {
      path.quadraticBezierTo(0, h / 2, w * 2 / 3, h);
      path.quadraticBezierTo(w / 3, h / 3, w, 0);
      path.lineTo(0, 0);
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
