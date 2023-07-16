import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override

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
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 12, 1, 60)),
          useMaterial3: true,
        ),
        home: const DrawingWrapper());
  }
}

class DrawingWrapper extends StatefulWidget {
  const DrawingWrapper({super.key});

  @override
  _DrawingWrapperState createState() => _DrawingWrapperState();
}

class _DrawingWrapperState extends State<DrawingWrapper> {
  Color strokeColor = Colors.black;
  double strokeWidth = 5;

  void _setColor(Color color) {
    setState(() {
      strokeColor = color;
    });
  }

  void _setStrokeWidth(double newStrokeWidth) {
    setState(() {
      strokeWidth = newStrokeWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Stack(children: [
          DrawingCanvas(
              strokeWidth: strokeWidth, color: strokeColor, fill: false),
          Row(
            children: [
              IconButton(
                color: Colors.blue,
                onPressed: () => {_setColor(Colors.blue)},
                icon: const Icon(Icons.water_drop),
              ),
              IconButton(
                color: Colors.red,
                onPressed: () => {_setColor(Colors.red)},
                icon: const Icon(Icons.fire_truck),
              ),
              IconButton(
                color: Colors.amber,
                onPressed: () => {_setColor(Colors.amber)},
                icon: const Icon(Icons.rocket_launch),
              ),
              IconButton(
                color: Colors.green,
                onPressed: () => {_setColor(Colors.green)},
                icon: const Icon(Icons.travel_explore),
              ),
              IconButton(
                color: Colors.purple,
                onPressed: () => {_setColor(Colors.purple)},
                icon: const Icon(Icons.dangerous),
              )
            ],
          )
        ]));
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
  List<DrawingObject> drawingObjectList = <DrawingObject>[];
  List<Offset> newDrawing = <Offset>[];

  void _drawPen(Offset point) {
    setState(() {
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
      drawingObjectList.add(DrawingObject(
          pointList: newDrawing,
          paint: Paint()
            ..color = widget.color
            ..strokeWidth = widget.strokeWidth
            ..style = PaintingStyle.stroke
            ..isAntiAlias = true));
      newDrawing = <Offset>[];
    });
  }

  void _undo() {
    setState(() {
      drawingObjectList = drawingObjectList
          .getRange(0,
              drawingObjectList.length > 1 ? drawingObjectList.length - 2 : 1)
          .toList();
    });
  }

  void _empty() {
    setState(() {
      drawingObjectList.clear();
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
              objectList: drawingObjectList,
            ),
            child: Container(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
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

class DrawingObject {
  List<Offset> pointList = <Offset>[];
  Paint paint = Paint()
    ..color = Colors.black
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 2
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;

  DrawingObject({required this.pointList, required this.paint});
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
  List<DrawingObject> objectList = <DrawingObject>[];

  ObjectPainter({
    required this.objectList,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (objectList.isNotEmpty) {
      for (int i = 0; i < objectList.length; i++) {
        Path path = Path();
        Paint paint = objectList[i].paint;
        if (objectList[i].pointList.isNotEmpty) {
          path.moveTo(
              objectList[i].pointList[0].dx, objectList[i].pointList[0].dy);
          for (int j = 1; (j < objectList[i].pointList.length - 1); j++) {
            path.lineTo(
                objectList[i].pointList[j].dx, objectList[i].pointList[j].dy);
          }
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ObjectPainter oldDelegate) =>
      oldDelegate.objectList.length == objectList.length;
}
