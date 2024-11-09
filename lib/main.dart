import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: RedSquare(),
        ),
      ),
    );
  }
}

class RedSquare extends StatefulWidget {
  const RedSquare({super.key});

  @override
  RedSquareState createState() => RedSquareState();
}

class RedSquareState extends State<RedSquare>
    with SingleTickerProviderStateMixin {
  double? _position;
  bool _isAnimating = false;
  late AnimationController _controller;
  bool _isButtonDisabled = false;

  late Animation<double> _animation;

  void _moveRight(double screenWidth, double squareSize) {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
    });

    double endPosition = screenWidth - squareSize;

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isButtonDisabled = false;
        });
      }
    });

    _animation = Tween<double>(begin: _position ?? 0, end: endPosition)
        .animate(_controller);

    _controller.forward(from: 0.0);
  }

  void _moveLeft(double screenWidth, double squareSize) {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
    });

    double endPosition = -screenWidth + squareSize;

    _animation = Tween<double>(begin: _position ?? 0, end: endPosition)
        .animate(_controller);

    _controller.forward(from: 0.0);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {
        _position = _animation.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (_isAnimating) {
          if (mounted) {
            setState(() {
              _isAnimating = false; // Set the flag to false
            });
          }

          // Print after setting the flag
        } else {}
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _position = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double squareSize = 50.0;
    double screenWidth = MediaQuery.sizeOf(context).width / 2 + squareSize / 2;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(_position ?? 0, 0),
          child: Container(
            width: squareSize,
            height: squareSize,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed:
                  !_isAnimating && (_position ?? 0) >= 0 && !_isButtonDisabled
                      ? () {
                          _moveLeft(screenWidth, squareSize);
                        }
                      : null,
              child: const Text('To Left'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed:
                  !_isAnimating && (_position ?? 0) <= 0 && !_isButtonDisabled
                      ? () {
                          _moveRight(screenWidth, squareSize);
                        }
                      : null,
              child: const Text('To Right'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.removeListener(() {});

    _controller.dispose();
    super.dispose();
  }
}
