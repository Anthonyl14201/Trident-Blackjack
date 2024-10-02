import 'package:flutter/material.dart';

class CardDealAnimation extends StatefulWidget {
  final Widget cardWidget; // The widget to animate
  final Offset startPosition; // Starting position for the animation
  final Offset endPosition; // Ending position for the animation
  final Duration duration; // Duration of the animation

  const CardDealAnimation({
    Key? key,
    required this.cardWidget,
    required this.startPosition,
    required this.endPosition,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CardDealAnimationState createState() => _CardDealAnimationState();
}

class _CardDealAnimationState extends State<CardDealAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.cardWidget,
    );
  }
}
