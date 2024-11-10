import 'dart:ui';
import 'package:flutter/material.dart';

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

  double getScaledSize(int index) {
    return baseItemHeight;
  }

  double getTranslationY(int index) {
    return baseTranslationY;
  }
// Update the getIconPosition to return a smooth transition value (animated over time).
double getIconPosition(int index) {
  if (draggedItem != null && hoveredIndex != null) {
    print('Dragged item: $draggedItem');
    print('Hovered index: $hoveredIndex');
    print('Current index: $index');
    
    if (index > hoveredIndex!) {
      print('Moving icon to the left (index > hoveredIndex)');
      return -50.0; // Slide icons to the left
    } else if (index < hoveredIndex!) {
      print('Moving icon to the right (index < hoveredIndex)');
      return 50.0; // Slide icons to the right
    }
  }
  print('No shift for icon at index $index');
  return 0.0; // No shift when not dragging or hoveredIndex is null
}


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
              child: SizedBox(
                width:
                    getDockWidth(), // Use getDockWidth here to set dynamic width
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Always center the icons
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(items.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10), // Spacing between icons
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
                                  setState(() {
                                    hoveredIndex = index;
                                  });
                                },
                                onExit: (event) {
                                  setState(() {
                                    hoveredIndex = null;
                                  });
                                },
                                child: Draggable<String>(
                                    data: items[index],
                                    onDragStarted: () {
                                      setState(() {
                                        draggedItem = items[index];
                                      });
                                    },
                                    onDraggableCanceled: (velocity, offset) {
                                      setState(() {
                                        draggedItem = null;
                                      });
                                    },
                                    childWhenDragging: SizedBox(
                                      height: getScaledSize(index),
                                      width: getScaledSize(index),
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
                                    child: AnimatedPositioned(
                                      duration: const Duration(
                                          seconds:
                                              5), // Set the animation duration
                                      left: getIconPosition(
                                          index), // Horizontal position change
                                      top: getTranslationY(
                                          index), // Vertical position change (optional)
                                      child: Transform.translate(
                                        offset: Offset(
                                          getIconPosition(
                                              index), // Horizontal movement (adjust)
                                          getTranslationY(
                                              index), // Vertical movement (adjust)
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            items[index],
                                            style: TextStyle(
                                                fontSize: getScaledSize(index)),
                                          ),
                                        ),
                                      ),
                                    )),
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

// Icons list
List<String> items = [
  '🌟',
  '😍',
  '💙',
  '👋',
  '🙀',
];
