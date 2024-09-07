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

  Deck() {
    List<String> suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    List<String> ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    Map<String, int> values = {
      '2': 2,
      '3': 3,
      '4': 4,
      '5': 5,
      '6': 6,
      '7': 7,
      '8': 8,
      '9': 9,
      '10': 10,
      'J': 10,
      'Q': 10,
      'K': 10,
      'A': 11,
    };

    for (var suit in suits) {
      for (var rank in ranks) {
        cards.add(PlayingCard(suit, rank, values[rank]!));
      }
    }

    shuffle();
  }

  void shuffle() {
    cards.shuffle();
  }

  PlayingCard drawCard() {
    return cards.removeLast();
  }
}
