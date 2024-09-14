import 'package:flutter/material.dart';
import '../models/deck.dart';  // Adjust the path based on your folder structure

class GameScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Deck deck = Deck(deckCount: 6); // Default to 6 decks
  List<PlayingCard> playerHand = [];
  List<PlayingCard> dealerHand = [];
  String result = '';
  bool roundOver = false;
  bool bettingPhase = true; // Player will bet before hands are dealt

  bool canDouble = false;
  bool canSplit = false;
  bool canSurrender = false;

  int balance = 1000; // Player starts with $1000
  int currentBet = 0; // Player's current bet

  final TextEditingController betController = TextEditingController(); // For text input

  @override
  void initState() {
    super.initState();
  }

  void startRound() {
    if (currentBet > 0) {
      playerHand = [deck.drawCard(), deck.drawCard()];
      dealerHand = [deck.drawCard(), deck.drawCard()];
      roundOver = false;
      bettingPhase = false; // End the betting phase when the round starts

      // Enable or disable options based on player's hand
      canDouble = playerHand.length == 2;
      canSplit = playerHand[0].rank == playerHand[1].rank;  // Check for matching ranks
      canSurrender = true; // Allow surrender before any other action

      setState(() {
        result = '';
      });
    }
  }

  void resetRound() {
    setState(() {
      currentBet = 0;
      bettingPhase = true; // Go back to betting phase
      result = '';
      playerHand.clear();
      dealerHand.clear();
    });
  }

  void playerHit() {
    setState(() {
      playerHand.add(deck.drawCard());
      if (calculateTotal(playerHand) > 21) {
        result = "Player busts!";
        roundOver = true;
        balance -= currentBet; // Deduct bet if the player busts
      }
      // Disable surrender after the first move
      canSurrender = false;
      canDouble = false;
    });
  }

  void playerStay() {
    while (calculateTotal(dealerHand) < 17) {
      dealerHand.add(deck.drawCard());
    }
    determineWinner();
    setState(() {
      roundOver = true;
    });
  }

  void determineWinner() {
    int playerTotal = calculateTotal(playerHand);
    int dealerTotal = calculateTotal(dealerHand);

    setState(() {
      if (dealerTotal > 21 || playerTotal > dealerTotal) {
        result = "Player wins!";
        balance += currentBet; // Add the bet to balance if the player wins
      } else if (dealerTotal > playerTotal) {
        result = "Dealer wins!";
        balance -= currentBet; // Deduct bet if dealer wins
      } else {
        result = "It's a tie!";
      }
    });
  }

  int calculateTotal(List<PlayingCard> hand) {
    int total = 0;
    int aces = 0;

    for (var card in hand) {
      total += card.value;
      if (card.rank == 'A') aces += 1;
    }

    while (total > 21 && aces > 0) {
      total -= 10; // Count an Ace as 1 instead of 11
      aces -= 1;
    }

    return total;
  }

  void doubleDown() {
    if (canDouble) {
      setState(() {
        currentBet *= 2; // Double the bet
        playerHand.add(deck.drawCard()); // Draw one card
        if (calculateTotal(playerHand) > 21) {
          result = "Player busts!";
          balance -= currentBet; // Deduct bet if the player busts
        } else {
          playerStay(); // End the turn after doubling down
        }
        roundOver = true;
        canDouble = false; // Prevent doubling after the first move
      });
    }
  }

  void split() {
    if (canSplit) {
      List<PlayingCard> secondHand = [playerHand.removeAt(1), deck.drawCard()];
      playerHand.add(deck.drawCard());
      // Handle the logic for playing the second hand here
      // Not fully implemented, but this gives you a starting point
      result = "Player split!";
      canSplit = false;
    }
  }

  void surrender() {
    if (canSurrender) {
      setState(() {
        balance -= currentBet ~/ 2; // Lose half the bet
        result = "Player surrenders!";
        roundOver = true;
        canSurrender = false; // Prevent surrender after the first move
      });
    }
  }

  void updateBet(int amount) {
    setState(() {
      currentBet += amount;
      betController.text = currentBet.toString(); // Update text field with new bet
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blackjack Game"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/config');  // Navigate to the config menu
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (bettingPhase) ...[
            Center(child: Text("Balance: \$${balance.toString()}")),  // Centered balance
            Center(child: Text("Current Bet: \$${currentBet.toString()}")),  // Centered bet
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0), // Add padding to center text field
              child: TextField(
                controller: betController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Enter your bet'),
                onChanged: (value) {
                  setState(() {
                    currentBet = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10, // Space between buttons
              alignment: WrapAlignment.center, // Center buttons in Wrap
              children: [
                ElevatedButton(onPressed: () => updateBet(1), child: Text("\$1")),
                ElevatedButton(onPressed: () => updateBet(5), child: Text("\$5")),
                ElevatedButton(onPressed: () => updateBet(10), child: Text("\$10")),
                ElevatedButton(onPressed: () => updateBet(20), child: Text("\$20")),
                ElevatedButton(onPressed: () => updateBet(50), child: Text("\$50")),
                ElevatedButton(onPressed: () => updateBet(100), child: Text("\$100")),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: startRound,
                child: Text("Start Round"),
              ),
            ),
          ] else ...[
            Center(child: Text("Your Hand: ${playerHand.join(', ')}")), // Centered hand
            Center(child: Text("Dealer's Cards: ${roundOver ? dealerHand.join(', ') : dealerHand[0]}")), // Centered dealer hand
            if (result.isNotEmpty)
              Center(child: Text(result, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))), // Centered result
            SizedBox(height: 20),
            if (!roundOver)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: playerHit,
                        child: Text("Hit"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: playerStay,
                        child: Text("Stay"),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: canDouble ? doubleDown : null,
                        child: Text("Double Down"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: canSplit ? split : null,
                        child: Text("Split"),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: canSurrender ? surrender : null,
                    child: Text("Surrender"),
                  ),
                ],
              ),
            if (roundOver)
              Center(
                child: ElevatedButton(
                  onPressed: resetRound,
                  child: Text("Start New Round"),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
