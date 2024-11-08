import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<IconData> icons = [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.file_copy_sharp,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
      ),
      body: Center(
        child: Dock(
          items: icons,
          onReorder: _onReorder,
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = icons.removeAt(oldIndex);
      icons.insert(newIndex, item);
    });
  }
}

class Dock extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.onReorder,
  });

  final List<IconData> items;
  final Function(int, int) onReorder;

  @override
  DockState createState() => DockState();
}

class DockState extends State<Dock> {
  late List<IconData> _items;
  late List<Offset> _itemPositions;
  Offset? _draggingPosition;
  int? _draggingIndex;
  final List<Offset> _dockPositions = [
    const Offset(0, 100),
    const Offset(75, 100),
    const Offset(150, 100),
    const Offset(225, 100),
    const Offset(300, 100),
  ];

  @override
  void initState() {
    super.initState();
    _items = [
      Icons.abc,
      Icons.book,
      Icons.call,
      Icons.delete,
      Icons.egg,
    ];
    _itemPositions =
        List.generate(_items.length, (index) => _dockPositions[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          ...List.generate(
            _items.length,
            (index) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 3000),
                left: _itemPositions[index].dx,
                top: _itemPositions[index].dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _draggingIndex ??= index;
                      _draggingPosition = details.localPosition;
                    });
                  },
                  onPanEnd: (_) {
                    setState(() {
                      if (_draggingPosition != null) {
                        final newIndex =
                            _getClosestDockPosition(_draggingPosition!);
                        final movedItem = _items.removeAt(_draggingIndex!);
                        _items.insert(newIndex, movedItem);

                        _shiftIcons();

                        _draggingPosition = null;
                        _draggingIndex = null;
                      }
                    });
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.primaries[index % Colors.primaries.length],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(_items[index], color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_draggingPosition != null && _draggingIndex != null)
            Positioned(
              left: _draggingPosition!.dx - 30,
              top: _draggingPosition!.dy - 30,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors
                      .primaries[_draggingIndex! % Colors.primaries.length],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(_items[_draggingIndex!], color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _getClosestDockPosition(Offset position) {
  double minDistance = double.infinity;
  int closestIndex = 0;

  for (int i = 0; i < _dockPositions.length; i++) {
    double distance = (position.dx - _dockPositions[i].dx).abs() +
        (position.dy - _dockPositions[i].dy).abs();
    if (distance < minDistance) {
      minDistance = distance;
      closestIndex = i;
    }
  }

  return closestIndex;
}

void _shiftIcons() {
  // Create a new list of positions based on the current item positions
  final newPositions = List<Offset>.from(_itemPositions);

  // If there's a valid dragging index and dragging position
  if (_draggingIndex != null && _draggingPosition != null) {
    final newIndex = _getClosestDockPosition(_draggingPosition!);

    // Check if the dragged icon has moved to a different position
    if (newIndex != _draggingIndex) {
      // Create space by shifting icons to the left or right
      if (newIndex > _draggingIndex!) {
        // Shift the icons after the dragged icon to the left (preserve the y-coordinate as 100)
        for (int i = _draggingIndex! + 1; i <= newIndex; i++) {
          newPositions[i] = Offset(
            _dockPositions[i - 1].dx, // Shift left, preserve the y-coordinate (set y to 100)
            100, // Set y to 100
          );
        }
      } else {
        // Shift the icons before the dragged icon to the right (preserve the y-coordinate as 100)
        for (int i = _draggingIndex! - 1; i >= newIndex; i--) {
          newPositions[i] = Offset(
            _dockPositions[i + 1].dx, // Shift right, preserve the y-coordinate (set y to 100)
            100, // Set y to 100
          );
        }
      }
      // Place the dragged icon at its new position, preserving y-coordinate (set y to 100)
      newPositions[newIndex] = Offset(
        _draggingPosition!.dx, // Use the dragged icon's x position
        100, // Set y to 100
      );
    }
  }

  // Update the item positions list to reflect the changes
  setState(() {
    _itemPositions = newPositions;
  });
}

}
