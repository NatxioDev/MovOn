import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutteropencv/screens/camera.dart';
import 'package:flutter/services.Dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mov On',
        home: CameraScreen());
  }
}
