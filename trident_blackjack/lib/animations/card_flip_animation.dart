import 'package:flutter/material.dart';

class CardFlipAnimation extends StatefulWidget {
  final Widget frontWidget;  // The face-up widget
  final Widget backWidget;   // The face-down widget
  final bool isFaceUp;       // Indicates if the card is face-up

  const CardFlipAnimation({
    Key? key,
    required this.frontWidget,
    required this.backWidget,
    this.isFaceUp = true,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CardFlipAnimationState createState() => _CardFlipAnimationState();
}

class _CardFlipAnimationState extends State<CardFlipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600), // Animation duration
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didUpdateWidget(CardFlipAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFaceUp != widget.isFaceUp) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final isFlipped = value > 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(value * 3.14), // Flip the card
          child: Container(
            width: 60,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: isFlipped ? widget.backWidget : widget.frontWidget,
          ),
        );
      },
    );
  }
}
