import 'dart:math';

import 'package:flutter/material.dart';

class GraphScreen extends StatefulWidget {
  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  Map<String, Offset> nodes = {};
  List<Edge> edges = [];
  TextEditingController nodeController = TextEditingController();
  TextEditingController edgeController = TextEditingController();
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  List<String> path = [];
  int totalDistance = 0;
  final double padding = 50.0; // Padding qiymati

  void addNode(String label) {
    if (!nodes.containsKey(label)) {
      nodes[label] = Offset(
        Random().nextDouble() * 300,
        Random().nextDouble() * 500,
      );
      setState(() {});
    }
  }

  void addEdge(String from, String to, int weight) {
    if (nodes.containsKey(from) && nodes.containsKey(to)) {
      edges.add(Edge(from, to, weight));
      setState(() {});
    }
  }

  void _removeNode(String nodeKey) {
    setState(() {
      nodes.remove(nodeKey);
      edges.removeWhere((edge) => edge.from == nodeKey || edge.to == nodeKey);
    });
  }

  // 📌 Bosilgan joyga qarab tugunni topish
  void _handleTap(TapUpDetails details) {
    Offset tappedPosition = details.localPosition - Offset(padding, padding);

    for (var entry in nodes.entries) {
      if ((entry.value - tappedPosition).distance < 20) {
        _removeNode(entry.key);
        break;
      }
    }
  }

  void findPath() {
    Set<String> visited = {};
    path.clear();
    totalDistance = 0;
    _dfs(startController.text, endController.text, visited, 0, []);
  }

  void _dfs(
    String current,
    String target,
    Set<String> visited,
    int distance,
    List<String> currentPath,
  ) {
    if (current == target) {
      path = List.from(currentPath)..add(current);
      totalDistance = distance;
      setState(() {});
      return;
    }
    visited.add(current);
    currentPath.add(current);
    for (var edge in edges.where((e) => e.from == current)) {
      if (!visited.contains(edge.to)) {
        _dfs(
          edge.to,
          target,
          visited,
          distance + edge.weight,
          List.from(currentPath),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          "Holatlar fazosida chuqurlik bo'yicha izlash",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: nodeController,
                          decoration: InputDecoration(
                            labelText: "Tugun nomi",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle),
                      onPressed: () => addNode(nodeController.text),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: edgeController,
                          decoration: InputDecoration(
                            labelText: "Bog'lanish (A->B, Masofa)",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_link),
                      onPressed: () {
                        var parts = edgeController.text.split(",");
                        if (parts.length == 2) {
                          var edge = parts[0].split("->");
                          int weight = int.tryParse(parts[1]) ?? 0;
                          if (edge.length == 2 && weight > 0) {
                            addEdge(edge[0], edge[1], weight);
                          }
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: startController,
                          decoration: InputDecoration(
                            labelText: "Boshlang'ich tugun",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: endController,
                          decoration: InputDecoration(
                            labelText: "Tugash tuguni",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),

                      onPressed: findPath,
                      child: Text(
                        "DFS Yo'l",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  "Topilgan yo'l: ${path.join(" -> ")}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Masofa: $totalDistance",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: GestureDetector(
                    onTapUp: _handleTap, // ✅ Tugun bosilganda chaqiramiz
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          width: 1000,
                          height: 800,
                          color: Colors.white,
                          child: CustomPaint(
                            painter: GraphPainter(
                              nodes,
                              edges,
                              path,
                              padding: padding,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Edge {
  final String from, to;
  final int weight;

  Edge(this.from, this.to, this.weight);
}

class GraphPainter extends CustomPainter {
  final Map<String, Offset> nodes;
  final List<Edge> edges;
  final List<String> path;
  final double padding;

  GraphPainter(this.nodes, this.edges, this.path, {this.padding = 50.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2;

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    final edgeTextStyle = TextStyle(color: Colors.black, fontSize: 14);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // 🔹 Tugunlarni padding bilan moslashtirish
    Map<String, Offset> adjustedNodes = {
      for (var entry in nodes.entries)
        entry.key: entry.value + Offset(padding, padding),
    };

    // 🔹 Yo‘llarni chizish
    for (var edge in edges) {
      Offset start = adjustedNodes[edge.from]!;
      Offset end = adjustedNodes[edge.to]!;
      canvas.drawLine(start, end, paint);

      // Masofani joylashtirish
      textPainter.text = TextSpan(text: "${edge.weight}", style: edgeTextStyle);
      textPainter.layout();
      Offset mid = Offset(
        (start.dx + end.dx) / 2 - textPainter.width / 2,
        (start.dy + end.dy) / 2 - textPainter.height / 2,
      );
      textPainter.paint(canvas, mid);
    }

    // 🔹 Tugunlarni chizish
    for (var entry in adjustedNodes.entries) {
      Offset center = entry.value;
      canvas.drawCircle(center, 20, paint..color = Colors.blue);

      // Tugun nomlarini chizish
      textPainter.text = TextSpan(text: entry.key, style: textStyle);
      textPainter.layout();
      Offset textOffset = Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
