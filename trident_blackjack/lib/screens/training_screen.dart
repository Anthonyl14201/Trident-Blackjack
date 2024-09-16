import 'package:flutter/material.dart';
import '../models/deck.dart';  // Adjust the path based on your folder structure

class GameScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Deck deck = Deck(deckCount: 6); // Default to 6 decks
  List<List<PlayingCard>> playerHands = []; // Store multiple hands after splitting
  int activeHandIndex = 0; // Track which hand is currently active
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
      playerHands = [
        [deck.drawCard(), deck.drawCard()]
      ];
      dealerHand = [deck.drawCard(), deck.drawCard()];
      activeHandIndex = 0;
      roundOver = false;
      bettingPhase = false; // End the betting phase when the round starts

      // Enable or disable options based on player's hand
      canDouble = playerHands[0].length == 2;
      canSplit = playerHands[0][0].value == playerHands[0][1].value;  // Check for matching ranks
      canSurrender = true; // Allow surrender before any other action
      if (isBlackjack(playerHands[0])) {
        double winnings = currentBet * 1.5;
        balance += winnings.toInt() + currentBet; // Add the winnings plus the original bet
        result = 'Player wins with Blackjack! You win \$${winnings.toStringAsFixed(2)}!';
        roundOver = true;
        setState(() {});
        return;
    }
      setState(() {
        result = '';
      });
    }
  }
  bool isBlackjack(List<PlayingCard> hand) {
    return hand.length == 2 && (hand[0].value == 1 && hand[1].value == 10 || hand[0].value == 10 && hand[1].value == 1);
  }

  void resetRound() {
    setState(() {
      currentBet = betController.text.isEmpty ? 0 : int.parse(betController.text);
      bettingPhase = true; // Go back to betting phase
      result = '';
      playerHands.clear();
      dealerHand.clear();
    });
  }

  void playerHit() {
    setState(() {
      playerHands[activeHandIndex].add(deck.drawCard());
      if (calculateTotal(playerHands[activeHandIndex]) > 21) {
        result = "Player busts on hand ${activeHandIndex + 1}!";
        balance -= currentBet; // Immediately deduct the bet if the player busts
        moveToNextHand();
      }
      // Disable surrender after the first move
      canSurrender = false;
      canDouble = false;
    });
  }

  void playerStay() {
    moveToNextHand();
  }

  void moveToNextHand() {
    if (activeHandIndex < playerHands.length - 1) {
      setState(() {
        activeHandIndex++;
        result = "";
        // Reset doubling and surrendering for the new hand
        canDouble = playerHands[activeHandIndex].length == 2;
        canSurrender = true;
        canSplit = playerHands[activeHandIndex][0].value == playerHands[activeHandIndex][1].value;
      });
    } else {
      playDealerHand();  // After the last hand, let the dealer play
    }
  }

  void playDealerHand() {
    while (calculateTotal(dealerHand) < 17) {
      dealerHand.add(deck.drawCard());
    }
    determineWinner();
    setState(() {
      roundOver = true;
    });
  }

  void determineWinner() {
  bool allHandsBust = true;

  // Check if all player hands have busted
  for (int i = 0; i < playerHands.length; i++) {
    if (calculateTotal(playerHands[i]) <= 21) {
      allHandsBust = false;
      break;
    }
  }

  // If not all hands bust, let the dealer draw
  if (!allHandsBust) {
    // Dealer draws until they reach at least 17
    while (calculateTotal(dealerHand) < 17) {
      dealerHand.add(deck.drawCard());
    }
  }

  // Compare results for each hand
  setState(() {
    int dealerTotal = calculateTotal(dealerHand);
    
    for (int i = 0; i < playerHands.length; i++) {
      int playerTotal = calculateTotal(playerHands[i]);

      if (playerTotal <= 21) { // Skip busted hands
        if (dealerTotal > 21 || playerTotal > dealerTotal) {
          result += "Player wins on hand ${i + 1}!\n";
          balance += currentBet; // Player wins
        } else if (dealerTotal > playerTotal) {
          result += "Dealer wins on hand ${i + 1}!\n";
          balance -= currentBet; // Dealer wins
        } else {
          result += "It's a tie on hand ${i + 1}!\n";
        }
      }
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
        playerHands[activeHandIndex].add(deck.drawCard()); // Draw one card for the active hand
        if (calculateTotal(playerHands[activeHandIndex]) > 21) {
          result = "Player busts on hand ${activeHandIndex + 1}!";
          balance -= currentBet; // Deduct bet if the player busts
        }
        moveToNextHand();
      });
    }
  }

  void split() {
    if (canSplit) {
      setState(() {
        List<PlayingCard> secondHand = [playerHands[activeHandIndex].removeAt(1), deck.drawCard()];
        playerHands[activeHandIndex].add(deck.drawCard());
        playerHands.add(secondHand);
        result = "Player splits!";
        canSplit = false; 
      });
    }
  }

  void surrender() {
    if (canSurrender) {
      setState(() {
        balance -= currentBet ~/ 2; // Lose half the bet
        result = "Player surrenders on hand ${activeHandIndex + 1}!";
        roundOver = true;
        canSurrender = false;
        moveToNextHand(); // Surrender only affects the current hand
      });
    }
  }

  void updateBet(int amount) {
    setState(() {
      currentBet += amount;
      betController.text = currentBet.toString(); // Update text field with new bet
    });
  }
  void clearBet() {
    setState(() {
      currentBet = 0; // Reset the bet to 0
      betController.text = currentBet.toString();
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
    body: Stack(  // Use Stack to overlay the card count in the top-left corner
      children: [
        Column(
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
                  ElevatedButton(onPressed: clearBet, child: Text("Clear")),
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
              // Display both hands if player has split
              Center(
                child: Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Hand 1: ",
                            style: TextStyle(
                              fontWeight: activeHandIndex == 0 ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: "${playerHands[0].join(', ')}", // Display Hand 1 cards
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    if (playerHands.length > 1)
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Hand 2: ",
                              style: TextStyle(
                                fontWeight: activeHandIndex == 1 ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: "${playerHands[1].join(', ')}", // Display Hand 2 cards
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Center(child: Text("Dealer's Cards: ${roundOver ? dealerHand.join(', ') : dealerHand[0]}")), // Show dealer hand
              if (result.isNotEmpty)
                Center(child: Text(result, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))), // Display result
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
        // Add this Positioned widget to display the remaining cards in the top-left corner
        Positioned(
          top: 10,
          left: 10,
          child: Text(
            'Cards remaining: ${deck.cardsRemaining()}',  // Make sure this calls the method that returns the card count
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}


}
