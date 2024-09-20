import '../models/hand.dart';
import '../models/deck.dart';

class BasicStrategy {
  static String getBestMove(Hand playerHand, PlayingCard dealerUpCard) {
    int dealerValue = _getCardValue(dealerUpCard);

    // Check if the player's hand is a pair first
    if (playerHand.isPair() && playerHand.cards[0].rank != 'A') {
      return _getPairMove(playerHand, dealerValue);
    }
    
    // Check if the player's hand is soft (Ace counted as 11)
    if (playerHand.isSoft()) {
      return _getSoftHandMove(playerHand, dealerValue);
    }

    // Default to hard hand logic
    return _getHardHandMove(playerHand, dealerValue);
  }

  // Helper function to get dealer's upcard value
  static int _getCardValue(PlayingCard card) {
    if (card.rank == 'J' || card.rank == 'Q' || card.rank == 'K') {
      return 10;
    } else if (card.rank == 'A') {
      return 11; // Ace is treated as 11 for dealer upcard
    }
    return card.value;
  }

  // Logic for pair splitting based on the player's hand and dealer's upcard
  static String _getPairMove(Hand playerHand, int dealerValue) {
    String rank = playerHand.cards[0].rank;

    switch (rank) {
      case '8':
        return 'Split';
      case '10':
        return 'Stand';
      case '9':
        return (dealerValue == 7 || dealerValue >= 10) ? 'Stand' : 'Split';
      case '7':
        return (dealerValue <= 7) ? 'Split' : 'Hit';
      case '6':
        return (dealerValue <= 6) ? 'Split' : 'Hit';
      case '5':
        return (dealerValue <= 9) ? 'Double Down' : 'Hit';
      case '4':
        return (dealerValue == 5 || dealerValue == 6) ? 'Split' : 'Hit';
      case '3':
      case '2':
        return (dealerValue <= 7) ? 'Split' : 'Hit';
      default:
        return 'Hit'; // fallback
    }
  }

  // Logic for soft hands based on player's hand and dealer's upcard
  static String _getSoftHandMove(Hand playerHand, int dealerValue) {
    int total = playerHand.getTotalValue();  // Soft hand total

    switch (total) {
      case 22:
        return (dealerValue >= 5 && dealerValue <= 6) ? 'Double Down' : 'Hit';
      case 19:
        return 'Stand';
      case 18:
        if (dealerValue >= 9) {
          return 'Hit';
        } else if (dealerValue == 3 || dealerValue == 4 || dealerValue == 5 || dealerValue == 6) {
          return 'Double Down';
        }
        return 'Stand';
      case 17:
        if (dealerValue == 3 || dealerValue == 4 || dealerValue == 5 || dealerValue == 6) {
          return 'Double Down';
        }
        else{
          return 'Hit';
        }
      case 16:
      case 15:
      case 14:
        return (dealerValue >= 4 && dealerValue <= 6) ? 'Double Down' : 'Hit';
      case 13:
        return (dealerValue >= 5 && dealerValue <= 6) ? 'Double Down' : 'Hit';
      default:
        return 'Should not have this case'; // fallback
    }
  }

  // Logic for hard hands based on player's hand and dealer's upcard
  static String _getHardHandMove(Hand playerHand, int dealerValue) {
    int total = playerHand.getTotalValue();  // Hard hand total

    if (total >= 17) {
      return 'Stand';
    } else if (total == 16) {
      if (dealerValue >= 9 || dealerValue == 11) {
        return 'Surrender'; // Special case for surrender
      }
      return (dealerValue <= 6) ? 'Stand' : 'Hit';
    } else if (total == 15 && dealerValue == 10) {
      return 'Surrender'; // Special case for surrender
    } else if (total >= 13 && total <= 16) {
      return (dealerValue <= 6) ? 'Stand' : 'Hit';
    } else if (total == 12) {
      return (dealerValue >= 4 && dealerValue <= 6) ? 'Stand' : 'Hit';
    } else if (total == 11) {
      return (dealerValue == 11) ? 'Hit' : 'Double Down'; // Adjusted for Ace
    } else if (total == 10) {
      return (dealerValue <= 9) ? 'Double Down' : 'Hit';
    } else if (total == 9) {
      return (dealerValue >= 3 && dealerValue <= 6) ? 'Double Down' : 'Hit';
    } else {
      return 'Hit'; // 8 or below
    }
  }
}
