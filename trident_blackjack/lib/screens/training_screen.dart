import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blackjack Game'),
      ),
      body: Center(
        child: Text('Game in progress...'),
      ),
    );
  }
}
