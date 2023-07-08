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
      title: 'Flutter Demo',
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
      home: const DrawingWidget(title: 'Flutter Demo Home Page'),
    );
  }
}

class DrawingWidget extends StatefulWidget {
  const DrawingWidget({super.key, required this.title});

  final String title;

  @override
  State<DrawingWidget> createState() => _DrawingWidgetState();
}

class _DrawingWidgetState extends State<DrawingWidget> {
  List<DrawingPoint> _DrawingPointList = [];

  void _deleteDrawing() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _DrawingPointList = [];
    });
  }

  void _addDrawingPoint(Offset offset) {
    setState(() {
      _DrawingPointList.add(DrawingPoint(
          offset,
          Paint()
            ..color = Colors.black
            ..isAntiAlias = true
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height - 60,
                width: MediaQuery.of(context).size.width,
                color: Colors.grey,
                child: GestureDetector(
                  onPanStart: (details) {
                    print("PanStart");
                    print(details.globalPosition);
                    print(details.localPosition);
                  },
                  onPanUpdate: (details) {
                    _addDrawingPoint(details.localPosition);
                  },
                  onPanEnd: (details) {
                    print("end");
                  },
                  child: CustomPaint(
                      size: const Size(300, 300),
                      painter: _DrawingPainter(_DrawingPointList),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      )),
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _deleteDrawing,
        tooltip: 'Clear',
        child: const Icon(Icons.delete),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  _DrawingPainter(this.drawingPoints);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < drawingPoints.length - 2; i++) {
      canvas.drawLine(drawingPoints[i].offset, drawingPoints[i + 1].offset,
          drawingPoints[i].paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPoint {
  Offset offset;
  Paint paint;

  DrawingPoint(this.offset, this.paint);
}
