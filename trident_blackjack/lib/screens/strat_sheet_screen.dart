import 'package:flutter/material.dart';

class StrategySheetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blackjack Strategy Sheet'),
      ),
      body: Center(
        child: StrategySheet(),
      ),
    );
  }
}
class StrategySheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      // Boundary to prevent scaling below or beyond desired limits
      minScale: 1.0, // Minimum zoom scale (1.0 means full fit on screen)
      maxScale: 3.0, // You can adjust this as needed for max zoom
      panEnabled: true, // Allow panning
      scaleEnabled: true, // Enable scaling
      child: AspectRatio(
        aspectRatio: MediaQuery.of(context).size.width / MediaQuery.of(context).size.height, // Match screen aspect ratio
        child: Image.asset(
          'assets/images/strategy-sheet.png',
          fit: BoxFit.contain, // Ensure the image fits within the screen without being cut off
        ),
      ),
    );
  }
}