import 'package:flutter/material.dart';
import 'package:trident_blackjack/models/deck.dart';
import 'package:trident_blackjack/models/hand.dart';  // Import the Hand class
import 'package:shared_preferences/shared_preferences.dart';
import 'config_screen.dart';  // Import the ConfigScreen class
import '../services/basic_strat_logic.dart';  // Import the BasicStrategy class
import '../widgets/playing_card_widget.dart';

class GameScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int numberOfDecks = 2;
  Deck deck = Deck(numberOfDecks: 6); // Default to 6 decks
  List<Hand> playerHands = []; // Store multiple hands after splitting
  Hand dealerHand = Hand();
  int activeHandIndex = 0; // Track which hand is currently active
  String result = '';
  bool roundOver = true;
  bool bettingPhase = true; // Player will bet before hands are dealt

  bool canDouble = false;
  bool canSplit = false;
  bool canSurrender = false;

  int balance = 1000; // Player starts with $1000
  int currentBet = 0; // Player's current bet

  final TextEditingController betController = TextEditingController(); // For text input
  bool showLight = true; // Track whether to show the light
  Color lightColor = Colors.black; // Default light color
  Offset dealerCardStartPosition = Offset(10, 10); // Cards start from top-right corner
  Offset playerCardStartPosition = Offset(10, 10); // Same start position for player cards

  List<Offset> playerCardPositions = [];
  List<Offset> dealerCardPositions = [];


  @override
  void initState() {
    super.initState();
    _loadConfig(); // Load configuration when initializing the game screen
  }

  // Load config from shared preferences
  Future<void> _loadConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      numberOfDecks = prefs.getInt('numberOfDecks') ?? 6; // Load number of decks
      _reinitializeDeck(); // Reinitialize deck with the loaded number of decks
    });
  }
  void _reinitializeDeck() {
    setState(() {
      deck = Deck(numberOfDecks: numberOfDecks); // Reinitialize deck
      // Optionally reset hands and dealer hand
      playerHands = [];
      dealerHand = Hand();
    });
  }
  Future<void> _navigateToConfigScreen() async {
    final updatedNumberOfDecks = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigScreen(),
      ),
    );

    if (updatedNumberOfDecks != null) {
      setState(() {
        numberOfDecks = updatedNumberOfDecks;
        _reinitializeDeck();
      });
    }
  }

  Future<void> startRound() async {
  if (currentBet > 0) {
    playerHands = [Hand()];
    dealerHand = Hand();
    activeHandIndex = 0;
    roundOver = false;
    bettingPhase = false; // End the betting phase when the round starts
    lightColor = Colors.black; // Reset the light color

    // Debugging: Print the initial cards
    //print('hand.length: ${playerHands[0].cards.length}');
    //print('Player Hand 1: ${playerHands[0].getDisplayString()}');
    //print('Dealer Hand: ${dealerHand.getDisplayString()}');

    // Deal two cards to the player and dealer
    print("hi");
    await dealCardToPlayer(0);
    // Enable or disable options based on player's hand
    print(playerHands[0].getDisplayString());
    

    canDouble = playerHands[0].cards.length == 2;
    canSplit = playerHands[0].isPair(); // Check for matching ranks
    canSurrender = true; // Allow surrender before any other action

    // Check if the player or dealer has Blackjack
    bool dealerHasBlackjack = isBlackjack(dealerHand);
    if (isBlackjack(playerHands[0]) && !dealerHasBlackjack) {
      // Player has Blackjack
      double winnings = currentBet * 1.5;
      balance += winnings.toInt();
      result = 'Player wins with Blackjack!\nYou win \$${winnings.toStringAsFixed(2)}!';
      roundOver = true;
      setState(() {});
      return;
    }
    if (isBlackjack(playerHands[0]) && dealerHasBlackjack) {
      // Both player and dealer have Blackjack
      result = 'Somehow Dealer and Player got a Blackjack. Its a Push';
      roundOver = true;
      setState(() {});
      return;
    }
    if (dealerHasBlackjack) {
      // Dealer has Blackjack
      balance -= currentBet; // Deduct the bet if the dealer has Blackjack
      result = 'Dealer wins with Blackjack :((((';
      roundOver = true;
      setState(() {});
      return;
    }

    setState(() {
      result = '';
    });
  }
}
Future<void> dealCardToPlayer(int cardIndex) async {
  if (cardIndex < 2) {
    // Define the end position based on card index to avoid overlap
    Offset endPosition = Offset(20.0 * cardIndex, 100.0);

    // Add end position to playerCardPositions to trigger animation
    setState(() {
      playerCardPositions.add(endPosition);
    });

    // Wait for the delay before adding the card
    await Future.delayed(Duration(milliseconds: 500 * cardIndex));

    // After the delay, deal the card
    setState(() {
      playerHands[0].addCard(deck.drawCard());
    });

    // Deal card to the dealer after dealing to player
    await dealCardToDealer(cardIndex);
  }
}

Future<void> dealCardToDealer(int cardIndex) async {
  Offset endPosition = Offset(20.0 * cardIndex, 20.0); // Adjust as needed

  // Add end position to dealerCardPositions to trigger animation
  setState(() {
    dealerCardPositions.add(endPosition);
  });

  // Wait for the delay before adding the card
  await Future.delayed(Duration(milliseconds: 500 * cardIndex));

  // After the delay, deal the card
  setState(() {
    dealerHand.addCard(deck.drawCard());
  });

  // Continue the loop by dealing the next card to the player if necessary
  if (cardIndex < 1) {
    await dealCardToPlayer(cardIndex + 1);
  }
}




  bool isBlackjack(Hand hand) {
    return hand.cards.length == 2 && 
      (hand.cards[0].value == 11 && hand.cards[1].value == 10 || 
      hand.cards[0].value == 10 && hand.cards[1].value == 11);
  }

  void resetRound() {
    setState(() {
      currentBet = betController.text.isEmpty ? 0 : int.parse(betController.text);
      bettingPhase = true; // Go back to betting phase
      result = '';
      for (var hand in playerHands) {
        hand.cards.forEach((card) => deck.discardCard(card));
      }
    // Optionally: Discard the dealer's cards
      for (var card in dealerHand.cards) {
        deck.discardCard(card);
      }
      playerHands.clear();
      dealerHand.resetHand();
    });
  }

  void playerHit() {
    setState(() {
      evaluatePlayerMove('Hit');
      playerHands[activeHandIndex].addCard(deck.drawCard());
      if (playerHands[activeHandIndex].getTotalValue() > 21) {
        result = "Player busts on hand ${activeHandIndex + 1}!\n";
        balance -= currentBet; // Immediately deduct the bet if the player busts
        moveToNextHand();
      }
      // Disable surrender after the first move
      canSurrender = false;
      canDouble = false;
    });
  }

  void playerStay() {
    evaluatePlayerMove('Stand');
    moveToNextHand();
  }

  void moveToNextHand() {
    if (activeHandIndex < playerHands.length - 1) {
      setState(() {
        activeHandIndex++;
        //result = "";
        // Reset doubling and surrendering for the new hand
        canDouble = playerHands[activeHandIndex].cards.length == 2;
        canSurrender = true;
        canSplit = playerHands[activeHandIndex].isPair();
      });
    } else {
      if (playerHands.every((hand) => hand.getTotalValue() > 21 || hand.surrendered)) {
        setState(() {
          roundOver = true;
        });
      } 
      else {
        playDealerHand();  // After the last hand, let the dealer play
      }
    }
  }

  void playDealerHand() {
    while (dealerHand.getTotalValue() < 17) {
      dealerHand.addCard(deck.drawCard());
    }
    determineWinner();
    setState(() {
      roundOver = true;
    });
  }

  void determineWinner() {
    bool allHandsBust = true;

    // Check if all player hands have busted
    for (var hand in playerHands) {
      if (hand.getTotalValue() <= 21) {
        allHandsBust = false;
        break;
      }
    }

    // If not all hands bust, let the dealer draw
    if (!allHandsBust) {
      // Dealer draws until they reach at least 17
      while (dealerHand.getTotalValue() < 17) {
        dealerHand.addCard(deck.drawCard());
      }
    }

    // Compare results for each hand
    setState(() {
      int dealerTotal = dealerHand.getTotalValue();
      
      for (int i = 0; i < playerHands.length; i++) {
        if (playerHands[i].surrendered) {
          continue;
        }
        int playerTotal = playerHands[i].getTotalValue();

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

  void doubleDown() {
    if (canDouble) {
      setState(() {
        currentBet *= 2; // Double the bet
        evaluatePlayerMove('Double Down');
        playerHands[activeHandIndex].addCard(deck.drawCard()); // Draw one card for the active hand
        if (playerHands[activeHandIndex].getTotalValue() > 21) {
          result += "Player busts on hand ${activeHandIndex + 1}!\n";
          balance -= currentBet; // Deduct bet if the player busts
        }
        moveToNextHand();
      });
    }
  }

  void split() {
    if (canSplit) {
      setState(() {
        Hand secondHand = Hand();
        evaluatePlayerMove('Split');
        secondHand.addCard(playerHands[activeHandIndex].cards.removeAt(1));
        secondHand.addCard(deck.drawCard());
        playerHands[activeHandIndex].addCard(deck.drawCard());
        playerHands.add(secondHand);
        result = "Player splits!\n";
        canSplit = false; 
      });
    }
  }

  void surrender() {
    if (canSurrender) {
      setState(() {
        evaluatePlayerMove('Surrender');
        balance -= currentBet ~/ 2; // Lose half the bet
        result += "Player surrenders on hand ${activeHandIndex + 1}!\n";
        playerHands[activeHandIndex].surrendered = true;
        
        // Set the current hand's result to 'surrendered' and move to the next hand
        moveToNextHand(); // Immediately move to the next hand without checking hand totals
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
/* 
************************
EVALUATING PLAYERS MOVES
************************
*/
void evaluatePlayerMove(String playerMove) {
  // Get dealer's upcard
  PlayingCard dealerUpCard = dealerHand.cards[0]; 
  // Get the best move suggested by BasicStrategy
  String bestMove = BasicStrategy.getBestMove(playerHands[activeHandIndex], dealerUpCard);

  // Compare player's move with the best move
  if (playerMove == bestMove) {
    // Correct move: turn the light green
    setState(() {
      lightColor = Colors.green;
      showLight = true;
    });
  } else {
    // Incorrect move: turn the light red and show popup
    setState(() {
      lightColor = Colors.red;
      showLight = true;
    });
    // Show the popup with the correct move
    _showIncorrectMovePopup(bestMove);
  }
}

void _showIncorrectMovePopup(String correctMove) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Incorrect Move'),
        content: Text('The correct move was: $correctMove'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the popup
            },
          ),
        ],
      );
    },
  );
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Blackjack Game"),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
            onPressed: roundOver ? _navigateToConfigScreen : null,
            // Correctly navigate to the config screen
        ),
      ],
    ),
    body: Stack(  // Use Stack to overlay the card count in the top-left corner
      children: [
        Positioned(
          width: 111,
          height: 162,
          top: 10,
          right: 10,
          child: Padding(
            padding: const EdgeInsets.only(),
            child: PlayingCardWidget(
              rank: 'back', // Assuming you have a specific rank for the back card
              suit: 'back', // You may use a generic or placeholder value for suit
              isFaceUp: false, // The card is face-down
              shouldFlip: false, // Do not flip the card
              startPosition: Offset(0, 0), // Starting position
              endPosition: Offset(0, 0), // Ending position
            ),
          ),
        ),
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
                  ElevatedButton(onPressed: () => updateBet(25), child: Text("\$25")),
                  ElevatedButton(onPressed: () => updateBet(50), child: Text("\$50")),
                  ElevatedButton(onPressed: () => updateBet(100), child: Text("\$100")),
                  ElevatedButton(onPressed: () => updateBet(500), child: Text("\$500")),
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
                    Text(
                      "Dealer's Cards:",
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < dealerHand.cards.length; i++)
                          PlayingCardWidget(
                            rank: dealerHand.cards[i].rank,
                            suit: dealerHand.cards[i].suit,
                            isFaceUp: roundOver || i > 0,  // Show the dealer's first card face-down if round is not over
                            shouldFlip: roundOver || i > 0,
                            startPosition: Offset(10, -10),
                            endPosition: Offset(0, 0),
                          ),
                      ],
                    ),
                    for (int i = 0; i < playerHands.length; i++)
                      Column(
                        children: [
                          Text(
                            "Hand ${i + 1}:",
                            style: TextStyle(
                              fontWeight: activeHandIndex == i
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var card in playerHands[i].cards)
                                PlayingCardWidget(
                                  rank: card.rank,
                                  suit: card.suit,
                                  isFaceUp: true,  // Show player's cards face-up
                                  shouldFlip: true,
                                  startPosition: Offset(10, -10),
                                  endPosition: Offset(0, 0),
                                ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Display dealer's cards
              
              if (result.isNotEmpty)
                Center(child: Text(result, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))), // DISPLAY RESULT
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
                if (showLight)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightColor, // Light color changes based on player move
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