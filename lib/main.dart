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

class RedSquareState extends State<RedSquare> with SingleTickerProviderStateMixin {
  /// The current position of the red square on the x-axis.
  double? _position;

  /// Indicates if the square is currently animating.
  bool _isAnimating = false;

  /// Disables the button when the square is moving in one direction.
  bool _isButtonDisabled = false;

  /// The controller that drives the animation.
  late AnimationController _controller;

  /// The animation that moves the square.
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initializes the animation controller with a duration and vsync.
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Updates the position of the square as the animation progresses.
    _controller.addListener(() {
      setState(() {
        _position = _animation.value;
      });
    });

    // Listens for changes in the animation status.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        // Indicates that the animation is in progress.
        if (mounted) {
          setState(() {
            _isAnimating = true;
          });
        }
      }

      // Resets the animation status when completed or dismissed.
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        if (_isAnimating) {
          if (mounted) {
            setState(() {
              _isAnimating = false;
            });
          }
        }
      }
    });
  }

  /// Moves the red square to the right edge of the screen.
  ///  
  /// Parameters:
  /// - [screenWidth]: The width of the screen.
  /// - [squareSize]: The size of the red square.
  void _moveRight(double screenWidth, double squareSize) {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
    });

    double endPosition = screenWidth - squareSize;
    _animation = Tween<double>(begin: _position ?? 0, end: endPosition).animate(_controller);
    _controller.forward(from: 0.0);
  }

  /// Moves the red square to the left edge of the screen and disables the button temporarily.
  /// 
  /// Parameters:
  /// - [screenWidth]: The width of the screen.
  /// - [squareSize]: The size of the red square.
  void _moveLeft(double screenWidth, double squareSize) {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
      _isButtonDisabled = true;
    });

    double endPosition = -screenWidth + squareSize;
    _animation = Tween<double>(begin: _position ?? 0, end: endPosition).animate(_controller);
    _controller.forward(from: 0.0);

    // Enables the button after the animation completes.
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isButtonDisabled = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double squareSize = 50.0;
    double screenWidth = MediaQuery.sizeOf(context).width / 2 + squareSize / 2;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_position ?? 0, 0),
              child: child,
            );
          },
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
              onPressed: !_isAnimating && (_position ?? 0) >= 0 && !_isButtonDisabled
                  ? () {
                      _moveLeft(screenWidth, squareSize);
                    }
                  : null,
              child: const Text('To Left'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: !_isAnimating && (_position ?? 0) <= 0 && !_isButtonDisabled
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
    // Disposes of the animation controller to free resources.
    _controller.dispose();
    super.dispose();
  }
}