import 'package:flutter/material.dart';

void main() {
  runApp(const BeckCrmApp());
}

class BeckCrmApp extends StatelessWidget {
  const BeckCrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeckCRM',
      home: Scaffold(appBar: AppBar(title: const Text('BeckCRM'))),
    );
  }
}
