import 'package:flutter/material.dart';
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
                // Add more functionality here for other screens
              },
              child: Text('Settings'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add more functionality here for other screens
              },
              child: Text('Basic Strategy Sheet'),
            ),
          ],
        ),
      ),
    );
  }
}
