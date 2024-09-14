import 'package:trident_blackjack/models/deck.dart';

class Hand {
  List<PlayingCard> cards = [];
  bool isSplit = false;

  // Add a card to the hand
  void addCard(PlayingCard card) {
    cards.add(card);
  }

  // Get the total value of the hand
  int getTotalValue() {
    int total = 0;
    int aceCount = 0;

    for (var card in cards) {
      total += card.value;
      if (card.rank == 'A') {
        aceCount++;
      }
    }

    // Adjust Aces from 11 to 1 if needed
    while (total > 21 && aceCount > 0) {
      total -= 10;
      aceCount--;
    }

    return total;
  }

  // Check if the hand is a pair (for splitting)
  bool isPair() {
    return cards.length == 2 && cards[0].rank == cards[1].rank;
  }

  // Check if the hand is soft (has an Ace counted as 11)
  bool isSoft() {
    return getTotalValue() <= 21 && cards.any((card) => card.rank == 'A' && card.value == 11);
  }

  // Reset the hand (useful for starting new rounds)
  void resetHand() {
    cards.clear();
    isSplit = false;
  }
}
