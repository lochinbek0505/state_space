import 'dart:collection';

import 'package:flutter/material.dart';


class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController startController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  String result = "";

  // BFS algorithm
  List<int> bfs(int start, int goal) {
    List<int> path = [];
    Queue<List<int>> queue = Queue();
    queue.add([start]);

    while (queue.isNotEmpty) {
      List<int> currentPath = queue.removeFirst();
      int current = currentPath.last;

      if (current == goal) {
        return currentPath;
      }

      queue.add([...currentPath, current + 1]);
      queue.add([...currentPath, current * 2]);
    }
    return path;
  }

  // DFS algorithm
  List<int> dfs(int start, int goal) {
    List<int> path = [];
    Stack<List<int>> stack = Stack();
    stack.push([start]);

    while (stack.isNotEmpty) {
      List<int> currentPath = stack.pop();
      int current = currentPath.last;

      if (current == goal) {
        return currentPath;
      }

      stack.push([...currentPath, current + 1]);
      stack.push([...currentPath, current * 2]);
    }
    return path;
  }

  void performSearch(bool isBfs) {
    int start = int.tryParse(startController.text) ?? 0;
    int goal = int.tryParse(goalController.text) ?? 0;

    if (start <= 0 || goal <= 0) {
      setState(() {
        result = "Iltimos, to'g'ri sonlarni kiriting!";
      });
      return;
    }

    List<int> path = isBfs ? bfs(start, goal) : dfs(start, goal);
    setState(() {
      result = path.isNotEmpty ? "Topilgan yo'l: ${path.join(" → ")}" : "Yechim topilmadi";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DFS & BFS Search")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: startController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Boshlang'ich son"),
            ),
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Maqsad son"),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => performSearch(true),
                  child: const Text("BFS Izlash"),
                ),
                ElevatedButton(
                  onPressed: () => performSearch(false),
                  child: const Text("DFS Izlash"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(result, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class Stack<T> {
  final List<T> _list = [];
  void push(T value) => _list.add(value);
  T pop() => _list.removeLast();
  bool get isNotEmpty => _list.isNotEmpty;
}