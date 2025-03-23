import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:holatlar_fazosi/HomePage.dart';
import 'dart:async';

import 'VizualPage.dart';

void main() {
  runApp(const PathFindingApp());
}

class PathFindingApp extends StatelessWidget {
  const PathFindingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  GraphScreen(),
    );
  }
}
