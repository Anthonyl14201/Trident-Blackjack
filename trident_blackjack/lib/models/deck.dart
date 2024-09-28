class PlayingCard {
  String rank;  // e.g., "A", "2", "3", "J", "Q", "K"
  String suit;  // e.g., "Hearts", "Diamonds", "Clubs", "Spades"
  int value;    // e.g., 1 for Ace, 11 for Jack/Queen/King, etc.

  PlayingCard(this.rank, this.suit, this.value);

  @override
  String toString() {
    return '$rank of $suit';
  }
}

class Deck {
  List<PlayingCard> cards = [];
  List<PlayingCard> discardedCards = []; // To keep track of discarded cards

  Deck({int numberOfDecks = 1}) { // Default to 1 deck
    _createDeck(numberOfDecks);
  }

  void _createDeck(int numberOfDecks) {
    List<String> suits = ['hearts', 'diamonds', 'clubs', 'spades'];
    List<String> ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'jack', 'queen', 'king', 'ace'];
    Map<String, int> values = {
      '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9,
      '10': 10, 'jack': 10, 'queen': 10, 'king': 10, 'ace': 11,
    };

    cards.clear(); // Clear existing cards
    for (var i = 0; i < numberOfDecks; i++) {
      for (var suit in suits) {
        for (var rank in ranks) {
          cards.add(PlayingCard(rank, suit, values[rank]!));
        }
      }
    }

    shuffle();
  }

  void shuffle() {
    cards.shuffle();
  }

  void reshuffle() {
    // Add discarded cards back into the deck
    cards.addAll(discardedCards);
    discardedCards.clear();
    shuffle();
  }

  PlayingCard drawCard() {
    if (cards.isEmpty) {
      reshuffle(); // Reshuffle if the deck is empty
    }
    return cards.removeLast();
  }
  void discardCard(PlayingCard card) {
    discardedCards.add(card);
  }

  int cardsRemaining() {
    return cards.length;
  }
}
