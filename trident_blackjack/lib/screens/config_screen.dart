import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  int numberOfDecks = 2;
  bool dealerHitsSoft17 = false;
  bool canDoubleAfterSplit = false;
  String surrenderOption = 'No Surrender';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  // Load config from shared preferences
  Future<void> _loadConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      numberOfDecks = prefs.getInt('numberOfDecks') ?? 2;
      dealerHitsSoft17 = prefs.getBool('dealerHitsSoft17') ?? false;
      canDoubleAfterSplit = prefs.getBool('canDoubleAfterSplit') ?? false;
      surrenderOption = prefs.getString('surrenderOption') ?? 'No Surrender';
    });
  }

  // Save config to shared preferences
  Future<void> _saveConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('numberOfDecks', numberOfDecks);
    prefs.setBool('dealerHitsSoft17', dealerHitsSoft17);
    prefs.setBool('canDoubleAfterSplit', canDoubleAfterSplit);
    prefs.setString('surrenderOption', surrenderOption);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Number of Decks"),
            DropdownButton<int>(
              value: numberOfDecks,
              onChanged: (value) {
                setState(() {
                  numberOfDecks = value!;
                });
              },
              items: List.generate(7, (index) => index + 2)
                  .map((decks) => DropdownMenuItem(
                        value: decks,
                        child: Text("$decks Decks"),
                      ))
                  .toList(),
            ),
            SwitchListTile(
              title: Text("Dealer Hits on Soft 17"),
              value: dealerHitsSoft17,
              onChanged: (bool value) {
                setState(() {
                  dealerHitsSoft17 = value;
                });
              },
            ),
            SwitchListTile(
              title: Text("Can Double After Split"),
              value: canDoubleAfterSplit,
              onChanged: (bool value) {
                setState(() {
                  canDoubleAfterSplit = value;
                });
              },
            ),
            Text("Surrender Options"),
            DropdownButton<String>(
              value: surrenderOption,
              onChanged: (value) {
                setState(() {
                  surrenderOption = value!;
                });
              },
              items: ['No Surrender', 'Early Surrender', 'Late Surrender']
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveConfig();
                Navigator.pop(context); // Go back to game screen
              },
              child: Text("Save Settings"),
            ),
          ],
        ),
      ),
    );
  }
}
