import 'package:flutter/material.dart';
import '../models/deck.dart';  // Adjust the path based on your folder structure

class GameScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Deck deck = Deck();
  List<PlayingCard> playerHand = [];
  List<PlayingCard> dealerHand = [];
  String result = '';

  @override
  void initState() {
    super.initState();
    startRound();
  }

  void startRound() {
    playerHand = [deck.drawCard(), deck.drawCard()];
    dealerHand = [deck.drawCard(), deck.drawCard()];

    setState(() {
      result = ''; // Reset result at the start of each round
    });
  }

  void playerHit() {
    setState(() {
      playerHand.add(deck.drawCard());
      if (calculateTotal(playerHand) > 21) {
        result = "Player busts!";
      }
    });
  }

  void playerStay() {
    // Dealer's turn logic
    while (calculateTotal(dealerHand) < 17) {
      dealerHand.add(deck.drawCard());
    }
    determineWinner();
  }

  void determineWinner() {
    int playerTotal = calculateTotal(playerHand);
    int dealerTotal = calculateTotal(dealerHand);

    setState(() {
      if (dealerTotal > 21 || playerTotal > dealerTotal) {
        result = "Player wins!";
      } else if (dealerTotal > playerTotal) {
        result = "Dealer wins!";
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
      total -= 10; // Counting an Ace as 1 instead of 11
      aces -= 1;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Blackjack Game")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Your Hand: ${playerHand.join(', ')}"),
          Text("Dealer's Visible Card: ${dealerHand[0]}"),
          if (result.isNotEmpty)
            Text(result, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          if (result.isEmpty) // Only show hit/stay if the round isn't over
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: playerHit,
                  child: Text("Hit"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: playerStay,
                  child: Text("Stay"),
                ),
              ],
            ),
          if (result.isNotEmpty) // Show restart button if round is over
            ElevatedButton(
              onPressed: startRound,
              child: Text("Start New Round"),
            ),
        ],
      ),
    );
  }
}
