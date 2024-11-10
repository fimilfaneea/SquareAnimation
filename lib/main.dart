import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MacOsInspiredDoc(),
    );
  }
}

/// A MacOS-style dock widget that allows for item dragging and reordering.
class MacOsInspiredDoc extends StatefulWidget {
  const MacOsInspiredDoc({super.key});

  @override
  State<MacOsInspiredDoc> createState() => _MacOsInspiredDocState();
}

class _MacOsInspiredDocState extends State<MacOsInspiredDoc> {
  late int? hoveredIndex;
  late double baseItemHeight;
  late double baseTranslationY;
  late double verticalItemsPadding;
  String? draggedItem;

  /// Determines the vertical translation (Y-axis) offset for an icon based on its index.
  double getTranslationY(int index) {
    return baseTranslationY;
  }

  /// Calculates the position offset for an icon when an item is dragged, to give
  /// visual feedback for item reordering.
  double getIconPosition(int index) {
    if (draggedItem != null && hoveredIndex != null) {
      if (index > hoveredIndex!) {
        return -50.0;
      } else if (index < hoveredIndex!) {
        return 50.0;
      }
    }
    return 0.0; // Default position when draggedItem is not hovering or outside
  }

  /// Returns the current width of the dock, shrinking it when an item is dragged
  /// to simulate a "hovered" effect.
  double getDockWidth() {
    double baseDockWidth = baseItemHeight * items.length +
        verticalItemsPadding * (items.length + 1);

    if (draggedItem != null) {
      baseDockWidth *= 0.8;
    }

    return baseDockWidth;
  }

  @override
  void initState() {
    super.initState();
    hoveredIndex = null;
    baseItemHeight = 80;
    verticalItemsPadding = 20;
    baseTranslationY = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              height: baseItemHeight,
              left: 0,
              right: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.greenAccent],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: verticalItemsPadding),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: getDockWidth(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(items.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DragTarget<String>(
                          onAcceptWithDetails: (details) {
                            setState(() {
                              items.remove(draggedItem);
                              items.insert(index, draggedItem!);
                              draggedItem = null;
                            });
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Opacity(
                              opacity: candidateData.isNotEmpty ? 0.5 : 1.0,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                onEnter: (event) {
                                  if (draggedItem != null) {
                                    setState(() {
                                      hoveredIndex =
                                          index; // Update hoveredIndex only when an item is being dragged
                                    });
                                  }
                                },
                                onExit: (event) {
                                  // Keep hoveredIndex unchanged, so the last hovered index stays
                                },
                                child: Draggable<String>(
                                  data: items[index],
                                  onDragStarted: () {
                                    setState(() {
                                      draggedItem = items[index];
                                    });
                                  },
                                  onDragUpdate: (details) {
                                    setState(() {
                                      final itemWidth =
                                          MediaQuery.of(context).size.width /
                                              items.length;
                                      hoveredIndex =
                                          (details.localPosition.dx /
                                                  itemWidth)
                                              .floor();
                                    });
                                  },
                                  onDraggableCanceled: (velocity, offset) {
                                    setState(() {
                                      draggedItem = null;
                                    });
                                  },
                                  childWhenDragging: SizedBox(
                                    height: baseItemHeight,
                                    width: baseItemHeight,
                                  ),
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      alignment: Alignment.center,
                                      child: Text(
                                        items[index],
                                        style: const TextStyle(fontSize: 40),
                                      ),
                                    ),
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(seconds: 1),
                                    transform: Matrix4.translationValues(
                                      getIconPosition(index),
                                      getTranslationY(index),
                                      0,
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(
                                        items[index],
                                        style: const TextStyle(
                                          fontSize: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// List of items displayed in the dock as draggable icons.
List<String> items = [
  '📱', 
  '💻', 
  '💾', 
  '🔋', 
  '⚙️', 
];
