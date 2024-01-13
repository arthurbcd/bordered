import 'package:bordered/bordered.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Transform.scale(
            scale: 3,
            child: AnimatedBordered(
              duration: const Duration(seconds: 1),
              elevation: 30,
              borderRadius: const BorderRadius.all(Radius.elliptical(40, 40))
                  .withDepth(1),
              border: UiBorder.all(
                width: 5,
                strokeAlign: -1,
              ),
              child: Container(
                width: 200,
                height: 200,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
