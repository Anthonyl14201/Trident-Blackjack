import 'package:flutter/material.dart';
import 'screens/main_menu.dart';  // Import your main menu screen
import 'screens/config_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blackjack Game',
      theme: ThemeData(
        primarySwatch: Colors.green, // Feel free to style the theme
      ),
      home: MainMenu(),
      routes: {
        '/config': (context) => ConfigScreen(),  // Add your config screen route
      }
    );
  }
}
