import 'package:flutter/material.dart';
import '../animations/card_flip_animation.dart';
import '../animations/card_deal_animation.dart';

class PlayingCardWidget extends StatelessWidget {
  final String rank;  // e.g., "ace", "10", "king", "queen", "jack" <- the way the image files are named
  final String suit;  // e.g., "spades", "hearts", "diamonds", "clubs"
  final bool isFaceUp; // Indicates if the card is face-up or face-down
  final bool shouldFlip; // Indicates if the card should flip
  final Offset startPosition; // Starting position for the deal animation
  final Offset endPosition; // Ending position for the deal animation

  PlayingCardWidget({
    required this.rank,
    required this.suit,
    this.isFaceUp = true, // Default value is face-up
    this.shouldFlip = true, // Default value is to flip the card
    required this.startPosition,
    required this.endPosition,
  });

  @override
  Widget build(BuildContext context) {
    return CardDealAnimation(
      cardWidget: shouldFlip
          ? CardFlipAnimation(
              frontWidget: _buildFaceUpCard(),
              backWidget: _buildFaceDownCard(),
              isFaceUp: isFaceUp,
            )
          : _buildFaceDownCard(), // Do not flip, just show the face-down card
      startPosition: startPosition,
      endPosition: endPosition,
    );
  }

  Widget _buildFaceUpCard() {
    return Image.asset(
      'assets/cards/${rank}_of_${suit}.png',  // Path for the card image
      fit: BoxFit.cover,
    );
  }

  Widget _buildFaceDownCard() {
    return Image.asset(
      'assets/cards/back.png',  // Path for the card back image
      fit: BoxFit.cover,
    );
  }
}
