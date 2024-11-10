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
    final size = getPropertyValue(
      index: index,
      baseValue: baseItemHeight,
      maxValue: 140,
      nonHoveredMaxValue: 100,
    );
    return size;
  }

  double getTranslationY(int index) {
    final translation = getPropertyValue(
      index: index,
      baseValue: baseTranslationY,
      maxValue: -44,
      nonHoveredMaxValue: -28,
    );
    return translation;
  }

  double getPropertyValue({
    required int index,
    required double baseValue,
    required double maxValue,
    required double nonHoveredMaxValue,
  }) {
    late final double propertyValue;

    if (hoveredIndex == null) {
      return baseValue;
    }

    final difference = (hoveredIndex! - index).abs();
    final itemsAffected = items.length;

    if (difference == 0) {
      propertyValue = maxValue;
    } else if (difference <= itemsAffected) {
      final ratio = (itemsAffected - difference) / itemsAffected;
      propertyValue = lerpDouble(baseValue, nonHoveredMaxValue, ratio)!;
    } else {
      propertyValue = baseValue;
    }

    return propertyValue;
  }

  @override
  void initState() {
    super.initState();
    hoveredIndex = null;
    baseItemHeight = 80;
    verticalItemsPadding = 20;
    baseTranslationY = 0.0;
  }

  double getDockWidth() {
  double baseDockWidth = baseItemHeight * items.length + verticalItemsPadding * (items.length +1);

  if (draggedItem != null) {
    baseDockWidth *= 0.8;  
  }

  return baseDockWidth;
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
                    getDockWidth(), 
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(items.length, (index) {
                    return DragTarget<String>(
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
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                transform: Matrix4.identity()
                                  ..translate(
                                    0.0,
                                    getTranslationY(index),
                                    0.0,
                                  ),
                                height: getScaledSize(index),
                                width: getScaledSize(index),
                                alignment: AlignmentDirectional.bottomCenter,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    items[index],
                                    style: TextStyle(
                                      fontSize: getScaledSize(index),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
