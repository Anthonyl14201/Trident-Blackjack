import 'package:flutter/material.dart';
import 'package:trident_blackjack/screens/config_screen.dart';
import 'training_screen.dart';  // Import the game screen

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blackjack Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the game screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen()),  // Pushes the GameScreen to the stack
                );
              },
              child: Text('Test your skills'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConfigScreen()),  // Pushes the GameScreen to the stack
                );
              },
              child: Text('Settings'),
            ),
            ElevatedButton(
              onPressed: () {
                //w
              },
              child: Text('Basic Strategy Sheet'),
            ),
          ],
        ),
      ),
    );
  }
}
