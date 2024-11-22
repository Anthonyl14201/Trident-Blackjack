import 'package:flutter/material.dart';
import 'package:trident_blackjack/screens/config_screen.dart';
import 'training_screen.dart';  // Import the game screen
import 'strat_sheet_screen.dart';  // Import the strategy sheet screen
import 'profile_screen.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'), //background image
                fit: BoxFit.cover, // Ensures the image fills the entire screen
              ),
            ),
          ),
          
          // Add profile and settings icons at the top
          Positioned(
            top: 40,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.person, color: Colors.black, size: 30),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Buttons Centered on Top of Background
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Customize button size
                    textStyle: TextStyle(fontSize: 20), // Customize text size
                  ),
                  onPressed: () {
                    // Navigate to the game screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GameScreen()),  // Pushes the GameScreen to the stack
                    );
                  },
                  child: Text('Test your skills'),
                ),
                SizedBox(height: 20),  // Space between buttons
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConfigScreen()),  // Pushes the ConfigScreen to the stack
                    );
                  },
                  child: Text('Settings'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StrategySheetScreen()),
                    );
                  },
                  child: Text('Basic Strategy Sheet'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
