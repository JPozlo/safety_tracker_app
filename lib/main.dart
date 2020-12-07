import 'package:flutter/material.dart';
import 'package:safety_tracker_app/ui/views.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapPage(title: 'Flutter Map Home Page'),
    );
  }
}

