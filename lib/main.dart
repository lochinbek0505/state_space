import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const PathFindingApp());
}

class PathFindingApp extends StatelessWidget {
  const PathFindingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PathFindingScreen(),
    );
  }
}

class PathFindingScreen extends StatefulWidget {
  const PathFindingScreen({super.key});

  @override
  State<PathFindingScreen> createState() => _PathFindingScreenState();
}

class _PathFindingScreenState extends State<PathFindingScreen> {
  static const int gridSize = 10;
  List<List<int>> grid = List.generate(gridSize, (i) => List.filled(gridSize, 0));
  final start = const Point(0, 0);
  final end = const Point(gridSize - 1, gridSize - 1);
  List<Point> path = [];

  Future<void> findPath(bool useBFS) async {
    setState(() => path.clear());
    List<Point> result = useBFS ? bfs(start, end) : dfs(start, end);
    for (var point in result) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() => path.add(point));
    }
  }

  List<Point> bfs(Point start, Point end) {
    Queue<List<Point>> queue = Queue();
    queue.add([start]);
    Set<Point> visited = {};

    while (queue.isNotEmpty) {
      var path = queue.removeFirst();
      var current = path.last;
      if (current == end) return path;
      if (visited.contains(current)) continue;
      visited.add(current);
      for (var neighbor in getNeighbors(current)) {
        queue.add([...path, neighbor]);
      }
    }
    return [];
  }

  List<Point> dfs(Point start, Point end) {
    Stack<List<Point>> stack = Stack();
    stack.push([start]);
    Set<Point> visited = {};

    while (stack.isNotEmpty) {
      var path = stack.pop();
      var current = path.last;
      if (current == end) return path;
      if (visited.contains(current)) continue;
      visited.add(current);
      for (var neighbor in getNeighbors(current)) {
        stack.push([...path, neighbor]);
      }
    }
    return [];
  }

  List<Point> getNeighbors(Point point) {
    List<Point> moves = [
      Point(0, 1),
      Point(1, 0),
      Point(0, -1),
      Point(-1, 0),
    ];
    return moves.map((m) => Point(point.x + m.x, point.y + m.y))
        .where((p) => p.x >= 0 && p.x < gridSize && p.y >= 0 && p.y < gridSize)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pathfinding Visualization")),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize),
              itemBuilder: (context, index) {
                int x = index % gridSize;
                int y = index ~/ gridSize;
                bool isStart = x == start.x && y == start.y;
                bool isEnd = x == end.x && y == end.y;
                bool isPath = path.contains(Point(x, y));
                return Container(
                  margin: const EdgeInsets.all(2),
                  color: isStart
                      ? Colors.green
                      : isEnd
                      ? Colors.red
                      : isPath
                      ? Colors.blue
                      : Colors.grey,
                );
              },
              itemCount: gridSize * gridSize,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => findPath(true),
                child: const Text("BFS"),
              ),
              ElevatedButton(
                onPressed: () => findPath(false),
                child: const Text("DFS"),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class Point {
  final int x, y;
  const Point(this.x, this.y);
  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;
  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class Stack<T> {
  final List<T> _list = [];
  void push(T element) => _list.add(element);
  T pop() => _list.removeLast();
  bool get isNotEmpty => _list.isNotEmpty;
}
