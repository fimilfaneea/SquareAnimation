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
    const Offset(0, 100), // Position for first "seat"
    const Offset(75, 100), // Position for second "seat"
    const Offset(150, 100), // Position for third "seat"
    const Offset(225, 100), // Position for fourth "seat"
    const Offset(300, 100), // Position for the new seat (fifth position)
  ];

  @override
  void initState() {
    super.initState();
    _items = [
      Icons.access_alarm,
      Icons.add_alert,
      Icons.star,
      Icons.home,
      Icons.file_copy_sharp // New icon added
    ];
    _itemPositions = List.generate(_items.length, (index) => _dockPositions[index % _dockPositions.length]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          // Render the icons with animation
          ...List.generate(
            _items.length,
            (index) {
              return AnimatedPositioned(
                duration: Duration(milliseconds: 300), // Set the duration of the animation
                left: _itemPositions[index].dx,
                top: _itemPositions[index].dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      // Set dragging index only when it's null
                      _draggingIndex ??= index;

                      // Update position based on pan movement for dragging
                      _draggingPosition = details.localPosition;
                    });
                  },
                  onPanEnd: (_) {
                    setState(() {
                      if (_draggingPosition != null) {
                        // Find the closest dock position for snapping
                        final newIndex = _getClosestDockPosition(_draggingPosition!);

                        // Rearrange the list of items based on the new position
                        final movedItem = _items.removeAt(_draggingIndex!);
                        _items.insert(newIndex, movedItem);

                        // Rearrange the positions based on the new item order
                        _itemPositions = List.generate(
                          _items.length,
                          (index) => _dockPositions[index % _dockPositions.length],
                        );

                        // Shift the icons
                        _shiftIcons();

                        // Reset dragging state
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
          // Render the icon being dragged (if exists)
          if (_draggingPosition != null && _draggingIndex != null)
            Positioned(
              left: _draggingPosition!.dx - 30, // Adjust to center the icon
              top: _draggingPosition!.dy - 30,
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.primaries[_draggingIndex! % Colors.primaries.length],
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

  // Function to find the closest dock position
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

  // Function to shift icons when a new item is inserted
  void _shiftIcons() {
    // Create a new list of positions based on the new order
    final newPositions = List.generate(_items.length, (index) {
      if (index < _draggingIndex!) {
        return _dockPositions[index]; // Icons before the dragged one
      } else if (index > _draggingIndex!) {
        return _dockPositions[index - 1]; // Icons after the dragged one shift left
      } else {
        return _dockPositions[index]; // Keep the dragged icon at its new position
      }
    });

    // Update the positions list
    setState(() {
      _itemPositions = newPositions;
    });
  }
}
