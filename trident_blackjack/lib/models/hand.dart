import 'deck.dart'; // Import the PlayingCard class

class Hand {
  List<PlayingCard> cards = [];
  bool surrendered = false;
  
  void addCard(PlayingCard card) {
    cards.add(card);
  }

  int getTotalValue() {
    int total = 0;
    int numAces = 0;

    for (var card in cards) {
      total += card.value;
      if (card.rank == 'Ace') {
        numAces++;
      }
    }
    // Adjust for Aces
    while (total > 21 && numAces > 0) {
      total -= 10;
      numAces--;
    }

    return total;
  }
  bool isSoft() {
      int numAces = 0;
      for (var card in cards) {
        if (card.rank == 'Ace') {
          numAces++;
        }
      }
      return numAces > 0;
    }
  String getDisplayString() {
    return cards.map((card) => '${card.rank} of ${card.suit}').join(', ');
  }

  bool isPair() {
    if (cards.length == 2) {
      return cards[0].value == cards[1].value;
    }
    return false;
  }

  void resetHand() {
    cards.clear();
  }
}
