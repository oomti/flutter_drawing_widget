import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Drawing Widget',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 12, 1, 60)),
          useMaterial3: true,
        ),
        home: Container(
            color: Colors.blue,
            child: DrawingCanvas(
                strokeWidth: 10, color: Colors.black, fill: false)));
  }
}

class DrawingCanvas extends StatefulWidget {
  final double strokeWidth;
  final Color color;
  final bool fill;

  DrawingCanvas(
      {this.strokeWidth = 5, this.color = Colors.blue, this.fill = false});

  @override
  _DrawingCanvasState createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<List<Offset>> objectList = <List<Offset>>[];
  List<Offset> newDrawing = <Offset>[];

  void _drawPen(Offset point) {
    setState(() {
      print(newDrawing.length);

      newDrawing.add(point);
    });
  }

  void _touchPen(Offset point) {
    setState(() {
      newDrawing = <Offset>[];
      newDrawing.add(point);
    });
  }

  void _raisePen() {
    setState(() {
      objectList.add(newDrawing);
      newDrawing = <Offset>[];
    });
  }

  void _undo() {
    setState(() {
      objectList = objectList.getRange(0, objectList.length - 2).toList();
      print(objectList.length);
    });
  }

  void _empty() {
    setState(() {
      objectList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          Offset localPosition = box.globalToLocal(details.globalPosition);
          _touchPen(localPosition);
        }
      },
      onPanUpdate: (details) {
        RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          Offset localPosition = box.globalToLocal(details.globalPosition);
          _drawPen(localPosition);
        }
      },
      onPanEnd: (details) {
        _raisePen();
      },
      onPanCancel: () {
        _raisePen();
      },
      child: Stack(
        children: [
          CustomPaint(
            painter: PenDrawingPainter(
              pointList: newDrawing,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
              fill: widget.fill,
            ),
            child: Container(),
          ),
          CustomPaint(
            painter: ObjectPainter(
              objectList: objectList,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
              fill: widget.fill,
            ),
            child: Container(),
          ),
          Row(
            children: [
              FloatingActionButton(
                onPressed: _empty,
                child: const Icon(Icons.delete),
              ),
              FloatingActionButton(
                onPressed: _undo,
                child: const Icon(Icons.arrow_back_rounded),
              )
            ],
          )
        ],
      ),
    );
  }
}

class PenDrawingPainter extends CustomPainter {
  List<Offset> pointList = <Offset>[];
  final double strokeWidth;
  final Color color;
  final bool fill;

  PenDrawingPainter(
      {required this.pointList,
      required this.strokeWidth,
      required this.color,
      required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
    Path path = Path();
    if (pointList.isNotEmpty) {
      path.moveTo(pointList[0].dx, pointList[0].dy);
      for (int j = 1; (j < pointList.length); j++) {
        path.lineTo(pointList[j].dx, pointList[j].dy);
      }
    }

    if (fill) {
      paint.style = PaintingStyle.fill;
    } else {
      paint.style = PaintingStyle.stroke;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PenDrawingPainter oldDelegate) =>
      oldDelegate.pointList.length == pointList.length;
}

class ObjectPainter extends CustomPainter {
  List<List<Offset>> objectList = <List<Offset>>[];
  final double strokeWidth;
  final Color color;
  final bool fill;

  ObjectPainter(
      {required this.objectList,
      required this.strokeWidth,
      required this.color,
      required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
    Path path = Path();
    if (objectList.isNotEmpty) {
      for (int i = 0; i < objectList.length; i++) {
        if (objectList[i].isNotEmpty) {
          path.moveTo(objectList[i][0].dx, objectList[i][0].dy);
          for (int j = 1; (j < objectList[i].length - 1); j++) {
            path.lineTo(objectList[i][j].dx, objectList[i][j].dy);
          }
          if (fill) {
            paint.style = PaintingStyle.fill;
          } else {
            paint.style = PaintingStyle.stroke;
          }
        }
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ObjectPainter oldDelegate) =>
      oldDelegate.objectList.length == objectList.length;
}
