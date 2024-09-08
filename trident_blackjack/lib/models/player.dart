class Player {
  int balance;
  int currentBet;

  Player({required this.balance, this.currentBet = 0});

  void placeBet(int amount) {
    if (balance >= amount) {
      currentBet += amount;
      balance -= amount;
    }
  }

  void resetBet() {
    balance += currentBet;
    currentBet = 0;
  }

  void winBet() {
    balance += currentBet * 2;
    currentBet = 0;
  }
}
